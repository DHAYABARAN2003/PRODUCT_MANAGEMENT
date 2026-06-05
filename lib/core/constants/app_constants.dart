/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'ShopVista';
  static const String appTagline = 'Discover Amazing Products';

  // Storage Keys
  static const String recentlyViewedKey = 'recently_viewed_products';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String themeModeKey = 'theme_mode';
  static const String cachedProductsKey = 'cached_products';

  // Limits
  static const int maxRecentlyViewed = 10;
  static const int searchDebounceMs = 500;
  static const int productsPerPage = 20;

  // Timeouts
  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Messages
  static const String offlineMessage = 'You are offline. Showing cached data.';
  static const String noProductsMessage = 'No products found';
  static const String searchHint = 'Search products...';
  static const String deleteConfirmTitle = 'Delete Product';
  static const String deleteConfirmMessage =
      'Are you sure you want to delete this product?';
}
