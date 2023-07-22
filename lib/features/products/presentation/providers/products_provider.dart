//* state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/presentation/providers/products_repository_provider.dart';

class ProductsState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Product> products;

  ProductsState({
    this.isLastPage = false,
    this.limit = 10,
    this.offset = 0,
    this.isLoading = false,
    this.products = const [],
  });

  ProductsState copyWith(
      {bool? isLastPage,
      int? limit,
      int? offset,
      bool? isLoading,
      List<Product>? products}) {
    return ProductsState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        products: products ?? this.products);
  }
}

//! Notifier
class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductsRepository productsRepository;
  ProductsNotifier({required this.productsRepository})
      : super(ProductsState()) {
    loadNextPage();
  }
  Future<bool> createUpdateProduct(Map<String, dynamic> productSpecs) async {
    try {
      final product =
          await productsRepository.createUpdateProduct(productSpecs);
      final isProductInState =
          state.products.any((element) => element.id == product.id);
      if (!isProductInState) {
        state = state.copyWith(products: [...state.products, product]);
        return true;
      }
      state = state.copyWith(
          products: state.products
              .map((e) => (e.id == product.id) ? product : e)
              .toList());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLastPage || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final products = await productsRepository.getProductsByPage(
        limit: state.limit, offset: state.offset);

    if (products.isEmpty) {
      state.copyWith(isLastPage: true, isLoading: false);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        products: [...state.products, ...products]);
  }
}

//? Provider

final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final productsRespository = ref.watch(productsRepositoryProvider);
  return ProductsNotifier(productsRepository: productsRespository);
});
