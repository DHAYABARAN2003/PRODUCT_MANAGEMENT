import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_management_app/core/network/api_client.dart';
import 'package:product_management_app/core/network/api_endpoints.dart';

import 'package:product_management_app/features/products/data/datasource/product_remote_datasource.dart';
import 'package:product_management_app/features/products/data/models/product_model.dart';

/// Implementation of [ProductRemoteDatasource] using [ApiClient].
class ProductRemoteDatasourceImpl implements ProductRemoteDatasource {
  final ApiClient _apiClient;

  ProductRemoteDatasourceImpl(this._apiClient);

  @override
  Future<ProductListResponse> getProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    final result = await _apiClient.get<ProductListResponse>(
      ApiEndpoints.products,
      queryParameters: {'limit': limit, 'skip': skip},
      parser: (data) => ProductListResponse.fromJson(data),
    );

    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final result = await _apiClient.get<ProductModel>(
      ApiEndpoints.productById(id),
      parser: (data) => ProductModel.fromJson(data),
    );

    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }

  @override
  Future<ProductListResponse> searchProducts(String query) async {
    final result = await _apiClient.get<ProductListResponse>(
      ApiEndpoints.searchProducts(query),
      parser: (data) => ProductListResponse.fromJson(data),
    );

    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }

  @override
  Future<ProductModel> addProduct(Map<String, dynamic> productData) async {
    final result = await _apiClient.post<ProductModel>(
      ApiEndpoints.addProduct,
      data: productData,
      parser: (data) => ProductModel.fromJson(data),
    );

    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }

  @override
  Future<ProductModel> updateProduct(
    int id,
    Map<String, dynamic> productData,
  ) async {
    final result = await _apiClient.put<ProductModel>(
      ApiEndpoints.updateProduct(id),
      data: productData,
      parser: (data) => ProductModel.fromJson(data),
    );

    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }

  @override
  Future<ProductModel> deleteProduct(int id) async {
    final result = await _apiClient.delete<ProductModel>(
      ApiEndpoints.deleteProduct(id),
      parser: (data) => ProductModel.fromJson(data),
    );

    return result.when(
      success: (data) => data,
      failure: (exception) => throw exception,
    );
  }
}

/// Provider for [ProductRemoteDatasource].
final productRemoteDatasourceProvider = Provider<ProductRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRemoteDatasourceImpl(apiClient);
});
