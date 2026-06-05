import 'package:product_management_app/features/products/data/models/product_model.dart';

abstract class ProductRepository {
  Future<ProductListResponse> getProducts({int limit = 20, int skip = 0});

  Future<ProductModel> getProductById(int id);

  Future<ProductListResponse> searchProducts(String query);

  Future<ProductModel> addProduct(Map<String, dynamic> productData);

  Future<ProductModel> updateProduct(int id, Map<String, dynamic> productData);

  Future<ProductModel> deleteProduct(int id);

  List<ProductModel>? getCachedProducts();

  Future<void> cacheProducts(List<ProductModel> products);

  Future<void> addRecentlyViewed(int productId);

  List<int> getRecentlyViewedIds();
}
