//! state
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';

class ProductState {
  final String id;
  final Product? product;
  final bool isLoading;
  final bool isSaving;

  ProductState({
    required this.id,
    this.product,
    this.isLoading = true,
    this.isSaving = false,
  });

  ProductState copyWith(
          {String? id, Product? product, bool? isLoading, bool? isSaving}) =>
      ProductState(
        id: id ?? this.id,
        product: product ?? this.product,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}

//* notifier

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductsRepository productsRepository;

  ProductNotifier({required this.productsRepository, required String productId})
      : super(ProductState(id: productId)) {
    loadProduct();
  }

  Future<void> loadProduct() async {
    try {
      final Product product =
          await productsRepository.getProductsById(state.id);
      state = state.copyWith(isLoading: false, product: product);
    } catch (e) {
      print(e);
    }
  }
}

//provider
final productProvider = StateNotifierProvider.autoDispose
    .family<ProductNotifier, ProductState, String>((ref, String productId) {
  final ProductsRepository productsRepository =
      ref.watch(productsRepositoryProvider);
  return ProductNotifier(
      productsRepository: productsRepository, productId: productId);
});
