import 'package:product_management_app/features/products/data/models/product_model.dart';

abstract class ProductRemoteDatasource {
  Future<ProductListResponse> getProducts({int limit = 20, int skip = 0});

  Future<ProductModel> getProductById(int id);

  Future<ProductListResponse> searchProducts(String query);

  Future<ProductModel> addProduct(Map<String, dynamic> productData);

  Future<ProductModel> updateProduct(int id, Map<String, dynamic> productData);

  Future<ProductModel> deleteProduct(int id);
}
