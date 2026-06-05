import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_management_app/core/constants/api_constants.dart';
import 'package:product_management_app/core/constants/app_constants.dart';

/// Provides a configured Dio instance with interceptors.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(
        milliseconds: AppConstants.connectionTimeout,
      ),
      receiveTimeout: const Duration(
        milliseconds: AppConstants.receiveTimeout,
      ),
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
        // Log request
        // ignore: avoid_print
        print(
          '┌── REQUEST ──────────────────────────────────────',
        );
        // ignore: avoid_print
        print('│ ${options.method} ${options.uri}');
        if (options.data != null) {
          // ignore: avoid_print
          print('│ Body: ${options.data}');
        }
        // ignore: avoid_print
        print(
          '└────────────────────────────────────────────────',
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response
        // ignore: avoid_print
        print(
          '┌── RESPONSE ─────────────────────────────────────',
        );
        // ignore: avoid_print
        print(
          '│ ${response.statusCode} ${response.requestOptions.uri}',
        );
        // ignore: avoid_print
        print(
          '└────────────────────────────────────────────────',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        // Log error
        // ignore: avoid_print
        print(
          '┌── ERROR ────────────────────────────────────────',
        );
        // ignore: avoid_print
        print(
          '│ ${error.response?.statusCode} ${error.requestOptions.uri}',
        );
        // ignore: avoid_print
        print('│ ${error.message}');
        // ignore: avoid_print
        print(
          '└────────────────────────────────────────────────',
        );
        handler.next(error);
      },
    ),
  );

  // Logger Interceptor
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: false,
      logPrint: (obj) {
        // Use a proper logger in production
      },
    ),
  );

  return dio;
});
