import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_management_app/features/products/data/datasource/product_local_datasource.dart';
import 'package:product_management_app/features/products/data/datasource/product_remote_datasource.dart';
import 'package:product_management_app/features/products/data/datasource/product_remote_datasource_impl.dart';
import 'package:product_management_app/features/products/data/models/product_model.dart';
import 'package:product_management_app/features/products/domain/repository/product_repository.dart';

/// Implementation of [ProductRepository] coordinating remote and local datasources.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource _remoteDatasource;
  final ProductLocalDatasource _localDatasource;

  ProductRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<ProductListResponse> getProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    final response = await _remoteDatasource.getProducts(
      limit: limit,
      skip: skip,
    );
    // Cache the results
    await _localDatasource.cacheProducts(response.products);
    return response;
  }

  @override
  Future<ProductModel> getProductById(int id) {
    return _remoteDatasource.getProductById(id);
  }

  @override
  Future<ProductListResponse> searchProducts(String query) {
    return _remoteDatasource.searchProducts(query);
  }

  @override
  Future<ProductModel> addProduct(Map<String, dynamic> productData) {
    return _remoteDatasource.addProduct(productData);
  }

  @override
  Future<ProductModel> updateProduct(
    int id,
    Map<String, dynamic> productData,
  ) {
    return _remoteDatasource.updateProduct(id, productData);
  }

  @override
  Future<ProductModel> deleteProduct(int id) {
    return _remoteDatasource.deleteProduct(id);
  }

  @override
  List<ProductModel>? getCachedProducts() {
    return _localDatasource.getCachedProducts();
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) {
    return _localDatasource.cacheProducts(products);
  }

  @override
  Future<void> addRecentlyViewed(int productId) {
    return _localDatasource.addRecentlyViewed(productId);
  }

  @override
  List<int> getRecentlyViewedIds() {
    return _localDatasource.getRecentlyViewedIds();
  }
}

/// Provider for [ProductRepository].
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDatasource = ref.watch(productRemoteDatasourceProvider);
  final localDatasource = ref.watch(productLocalDatasourceProvider);
  return ProductRepositoryImpl(remoteDatasource, localDatasource);
});
