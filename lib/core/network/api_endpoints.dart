import 'package:product_management_app/core/constants/api_constants.dart';
class ApiEndpoints {
  ApiEndpoints._();

  static String get products => ApiConstants.products;

  static String productById(int id) =>
      ApiConstants.productById.replaceAll('{id}', id.toString());

  static String searchProducts(String query) =>
      '${ApiConstants.searchProducts}?q=$query';

  static String get addProduct => ApiConstants.addProduct;

  static String updateProduct(int id) =>
      ApiConstants.updateProduct.replaceAll('{id}', id.toString());

  static String deleteProduct(int id) =>
      ApiConstants.deleteProduct.replaceAll('{id}', id.toString());
}
