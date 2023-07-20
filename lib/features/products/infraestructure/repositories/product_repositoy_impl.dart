import 'package:teslo_shop/features/products/domain/domain.dart';

class ProductRespositoryImpl extends ProductsRepository {
  final ProductsDatasource productsDatasource;

  ProductRespositoryImpl(this.productsDatasource);
  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productSpecs) {
    return productsDatasource.createUpdateProduct(productSpecs);
  }

  @override
  Future<Product> getProductsById(String id) {
    return productsDatasource.getProductsById(id);
  }

  @override
  Future<List<Product>> getProductsByPage({int limit = 10, int offset = 0}) {
    return productsDatasource.getProductsByPage(limit: limit, offset: offset);
  }

  @override
  Future<List<Product>> searchProductByTerm(String term) {
    return productsDatasource.searchProductByTerm(term);
  }
}
