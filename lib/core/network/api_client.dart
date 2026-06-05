import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_management_app/core/network/dio_provider.dart';
import 'package:product_management_app/core/network/network_exceptions.dart';
import 'package:product_management_app/core/errors/api_result.dart';
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// GET request
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return ApiResult.success(parser(response.data));
    } on DioException catch (e) {
      return ApiResult.failure(NetworkException.fromDioException(e));
    } catch (e) {
      return ApiResult.failure(
        UnknownException(message: e.toString()),
      );
    }
  }

  /// POST request
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResult.success(parser(response.data));
    } on DioException catch (e) {
      return ApiResult.failure(NetworkException.fromDioException(e));
    } catch (e) {
      return ApiResult.failure(
        UnknownException(message: e.toString()),
      );
    }
  }

  /// PUT request
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return ApiResult.success(parser(response.data));
    } on DioException catch (e) {
      return ApiResult.failure(NetworkException.fromDioException(e));
    } catch (e) {
      return ApiResult.failure(
        UnknownException(message: e.toString()),
      );
    }
  }

  /// DELETE request
  Future<ApiResult<T>> delete<T>(
    String path, {
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.delete(path);
      return ApiResult.success(parser(response.data));
    } on DioException catch (e) {
      return ApiResult.failure(NetworkException.fromDioException(e));
    } catch (e) {
      return ApiResult.failure(
        UnknownException(message: e.toString()),
      );
    }
  }
}

/// Riverpod provider for [ApiClient].
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
