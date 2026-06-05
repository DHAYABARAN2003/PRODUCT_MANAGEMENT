import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_management_app/core/constants/api_constants.dart';
import 'package:product_management_app/core/constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(
        milliseconds: AppConstants.connectionTimeout,
      ),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Request Interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print('┌── REQUEST ──────────────────────────────────────');
        print('│ ${options.method} ${options.uri}');
        if (options.data != null) {
          print('│ Body: ${options.data}');
        }
        print('└────────────────────────────────────────────────');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('┌── RESPONSE ─────────────────────────────────────');
       
        print('│ ${response.statusCode} ${response.requestOptions.uri}');
        
        print('└────────────────────────────────────────────────');
        handler.next(response);
      },
      onError: (error, handler) {
        print('┌── ERROR ────────────────────────────────────────');
        print('│ ${error.response?.statusCode} ${error.requestOptions.uri}');
        print('│ ${error.message}');
        print('└────────────────────────────────────────────────');
        handler.next(error);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: false,
      logPrint: (obj) {
      },
    ),
  );

  return dio;
});
