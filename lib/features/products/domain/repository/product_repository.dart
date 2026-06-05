import 'package:product_management_app/features/products/data/models/product_model.dart';

/// Abstract repository contract for product operations.
abstract class ProductRepository {
  /// Fetch all products with optional pagination.
  Future<ProductListResponse> getProducts({int limit = 20, int skip = 0});

  /// Get a single product by ID.
  Future<ProductModel> getProductById(int id);

  /// Search products by query.
  Future<ProductListResponse> searchProducts(String query);

  /// Add a new product.
  Future<ProductModel> addProduct(Map<String, dynamic> productData);

  /// Update an existing product.
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> productData);

  /// Delete a product.
  Future<ProductModel> deleteProduct(int id);

  /// Get cached products (for offline support).
  List<ProductModel>? getCachedProducts();

  /// Cache products locally.
  Future<void> cacheProducts(List<ProductModel> products);

  /// Add a product ID to recently viewed.
  Future<void> addRecentlyViewed(int productId);

  /// Get recently viewed product IDs.
  List<int> getRecentlyViewedIds();
}
