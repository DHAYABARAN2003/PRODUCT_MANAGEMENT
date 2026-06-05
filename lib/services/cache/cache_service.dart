import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_management_app/core/constants/app_constants.dart';
import 'package:product_management_app/services/local_storage/local_storage_service.dart';

/// Service for caching product data locally for offline support.
class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Cache products JSON response.
  Future<void> cacheProducts(String jsonResponse) async {
    await _prefs.setString(AppConstants.cachedProductsKey, jsonResponse);
  }

  /// Retrieve cached products JSON string.
  String? getCachedProducts() {
    return _prefs.getString(AppConstants.cachedProductsKey);
  }

  /// Cache recently viewed product IDs.
  Future<void> addRecentlyViewed(int productId) async {
    final ids = getRecentlyViewedIds();

    // Remove if already exists to move to front
    ids.remove(productId);

    // Add to front
    ids.insert(0, productId);

    // Limit to max size
    if (ids.length > AppConstants.maxRecentlyViewed) {
      ids.removeRange(AppConstants.maxRecentlyViewed, ids.length);
    }

    await _prefs.setString(
      AppConstants.recentlyViewedKey,
      jsonEncode(ids),
    );
  }

  /// Get recently viewed product IDs.
  List<int> getRecentlyViewedIds() {
    final jsonStr = _prefs.getString(AppConstants.recentlyViewedKey);
    if (jsonStr == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.cast<int>();
  }

  /// Clear cached products.
  Future<void> clearCache() async {
    await _prefs.remove(AppConstants.cachedProductsKey);
  }
}

/// Provider for [CacheService].
final cacheServiceProvider = Provider<CacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CacheService(prefs);
});
