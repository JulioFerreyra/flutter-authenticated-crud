import 'package:dio/dio.dart';

import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import '../infraestructure.dart';

class ProductDatasourceImpl extends ProductsDatasource {
  late final Dio dio;
  final String accessToken;
  ProductDatasourceImpl({required this.accessToken})
      : dio = Dio(BaseOptions(
          baseUrl: Enviorment.apiUrl,
          headers: {"Authorization": "Bearer $accessToken"},
        ));
  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productSpecs) {
    // TODO: implement getProductsById
    throw UnimplementedError();
  }

  @override
  Future<Product> getProductsById(String id) {
    // TODO: implement getProductsById
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> getProductsByPage(
      {int limit = 10, int offset = 0}) async {
    final response =
        await dio.get<List>("/api/products?limit=$limit&offset=$offset");
    final List<Product> products = [];
    for (final product in response.data ?? []) {
      products.add(ProductMapper.jsonToEntity(product));
    }
    return products;
  }

  @override
  Future<List<Product>> searchProductByTerm(String term) {
    // TODO: implement searchProductByTerm
    throw UnimplementedError();
  }
}
