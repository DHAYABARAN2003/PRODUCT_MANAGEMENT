import 'package:product_management_app/features/products/data/models/product_model.dart';

/// Remote datasource for product-related API calls.
abstract class ProductRemoteDatasource {
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
}
