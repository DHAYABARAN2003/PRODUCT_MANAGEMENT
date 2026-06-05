class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';

  // Endpoints
  static const String products = '/products';
  static const String productById = '/products/{id}';
  static const String searchProducts = '/products/search';
  static const String addProduct = '/products/add';
  static const String updateProduct = '/products/{id}';
  static const String deleteProduct = '/products/{id}';
  static const String productCategories = '/products/categories';
}
