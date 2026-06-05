import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_management_app/features/products/data/models/product_model.dart';
import 'package:product_management_app/services/cache/cache_service.dart';

/// Local datasource for cached product data.
abstract class ProductLocalDatasource {
  /// Get cached products.
  List<ProductModel>? getCachedProducts();

  /// Cache products.
  Future<void> cacheProducts(List<ProductModel> products);

  /// Add product ID to recently viewed.
  Future<void> addRecentlyViewed(int productId);

  /// Get recently viewed product IDs.
  List<int> getRecentlyViewedIds();
}

/// Implementation of [ProductLocalDatasource] using [CacheService].
class ProductLocalDatasourceImpl implements ProductLocalDatasource {
  final CacheService _cacheService;

  ProductLocalDatasourceImpl(this._cacheService);

  @override
  List<ProductModel>? getCachedProducts() {
    final jsonStr = _cacheService.getCachedProducts();
    if (jsonStr == null) return null;

    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final jsonStr = jsonEncode(products.map((e) => e.toJson()).toList());
    await _cacheService.cacheProducts(jsonStr);
  }

  @override
  Future<void> addRecentlyViewed(int productId) async {
    await _cacheService.addRecentlyViewed(productId);
  }

  @override
  List<int> getRecentlyViewedIds() {
    return _cacheService.getRecentlyViewedIds();
  }
}

/// Provider for [ProductLocalDatasource].
final productLocalDatasourceProvider = Provider<ProductLocalDatasource>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return ProductLocalDatasourceImpl(cacheService);
});
