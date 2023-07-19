import 'package:dio/dio.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/features/auth/domain/domain.dart';
import 'package:teslo_shop/features/auth/infraestructure/infrastructure.dart';

class AuthDataSourceImpl extends AuthDatasource {
  final dio = Dio(BaseOptions(baseUrl: Enviorment.apiUrl));
  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      final response = await dio.get(
        "/auth/check-status",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw CustomError("Token incorrecto");
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError(
            e.response?.data["message"] ?? "Tiempo de conexión agotado");
      }
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio
          .post("/auth/login", data: {"email": email, "password": password});
      final User user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw CustomError(
            e.response?.data["message"] ?? "Credenciales Invalidas");
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError(
            e.response?.data["message"] ?? "Tiempo de conexión agotado");
      }
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<User> register(String email, String password, String fullName) {
    // TODO: implement register
    throw UnimplementedError();
  }
}
