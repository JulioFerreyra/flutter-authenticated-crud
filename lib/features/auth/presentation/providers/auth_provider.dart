import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/domain/domain.dart';
import 'package:teslo_shop/features/auth/infraestructure/infrastructure.dart';

import '../../../shared/infraestructure/services/services.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final AuthRepository authRepository = AuthRespositoryImp();
  final KeyValueStorage keyValueStorage = KeyValueStorageImpl();
  return AuthNotifier(
      authRepository: authRepository, keyValueStorage: keyValueStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorage keyValueStorage;
  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorage,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> loginUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final user = await authRepository.login(email, password);
      _setLoggedUser(user);
    } on CustomError catch (e) {
      logOut(e.message);
    } catch (e) {
      logOut("Error no controlado");
    }
  }

  void registerUser(String email, String password) async {}

  void checkAuthStatus() async {
    final token = await keyValueStorage.getValue<String>("token");
    if (token == null) return logOut();
    try {
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user);
    } catch (e) {
      logOut();
    }
  }

  Future<void> logOut([String? errorMessage]) async {
    await keyValueStorage.removeKey("token");

    state = state.copyWith(
      errorMessage: errorMessage,
      authStatus: AuthStatus.notAuthenticated,
      user: null,
    );
  }

  void _setLoggedUser(User user) async {
    await keyValueStorage.setKeyValue("token", user.token);
    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: "",
    );
  }
}

enum AuthStatus { cheking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState(
      {this.authStatus = AuthStatus.cheking,
      this.user,
      this.errorMessage = ""});
  AuthState copyWith(
          {AuthStatus? authStatus, User? user, String? errorMessage}) =>
      AuthState(
          authStatus: authStatus ?? this.authStatus,
          user: user ?? this.user,
          errorMessage: errorMessage ?? this.errorMessage);
}
