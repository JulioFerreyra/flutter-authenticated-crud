import 'package:dio/dio.dart';

import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/features/auth/infraestructure/errors/auth_errors.dart';
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
  Future<Product> createUpdateProduct(Map<String, dynamic> productSpecs) async {
    try {
      final String? productId = productSpecs["id"];
      final String method = (productId == null) ? "POST" : "PATCH";
      final String url =
          (productId == null) ? "/products" : "/products/$productId";
      productSpecs.remove("id");
      productSpecs["images"] = await _uploadPhotos(productSpecs["images"]);

      final response = await dio.request(url,
          data: productSpecs, options: Options(method: method));
      final product = ProductMapper.jsonToEntity(response.data);
      return product;
    } on DioException catch (e) {
      throw CustomError(e.message ?? "Error en la petición");
    }
  }

  Future<String> _uploadFile(String path) async {
    try {
      final fileName = path.split("/").last;
      final FormData data = FormData.fromMap(
          {"file": MultipartFile.fromFileSync(path, filename: fileName)});
      final response = await dio.post("/files/product", data: data);
      return response.data["image"];
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<String>> _uploadPhotos(List<String> images) async {
    final photoToUpload =
        images.where((element) => element.contains("/")).toList();

    final photosToIgnore =
        images.where((element) => !element.contains("/")).toList();

    final List<Future<String>> uploadJobs =
        photoToUpload.map((e) => _uploadFile(e)).toList();
    final newImages = await Future.wait(uploadJobs);
    return [...photosToIgnore, ...newImages];
  }

  @override
  Future<Product> getProductsById(String id) async {
    try {
      final response = await dio.get("/products/$id");
      final Product product = ProductMapper.jsonToEntity(response.data);
      return product;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) {
        throw ProductNotFound();
      }

      throw Exception();
    } catch (e) {
      throw ProductNotFound();
    }
  }

  @override
  Future<List<Product>> getProductsByPage(
      {int limit = 10, int offset = 0}) async {
    final response =
        await dio.get<List>("/products?limit=$limit&offset=$offset");
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
