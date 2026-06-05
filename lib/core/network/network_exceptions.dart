import 'dart:io';
import 'package:dio/dio.dart';

/// Sealed class representing different network exception types.
sealed class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({required this.message, this.statusCode});

  factory NetworkException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const TimeoutException(
          message: 'Connection timeout. Please try again.',
        );
      case DioExceptionType.sendTimeout:
        return const TimeoutException(
          message: 'Send timeout. Please try again.',
        );
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
          message: 'Receive timeout. Please try again.',
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return const RequestCancelledException(
          message: 'Request was cancelled.',
        );
      case DioExceptionType.connectionError:
        return const NoInternetException(
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NoInternetException(
            message: 'No internet connection. Please check your network.',
          );
        }
        return UnknownException(
          message: error.message ?? 'An unexpected error occurred.',
        );
      default:
        return UnknownException(
          message: error.message ?? 'An unexpected error occurred.',
        );
    }
  }

  static NetworkException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'Something went wrong.';
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      message = data['message'] as String;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message: message, statusCode: statusCode);
      case 401:
        return UnauthorizedException(message: message, statusCode: statusCode);
      case 403:
        return ForbiddenException(message: message, statusCode: statusCode);
      case 404:
        return NotFoundException(message: message, statusCode: statusCode);
      case 500:
        return ServerException(message: message, statusCode: statusCode);
      default:
        return UnknownException(message: message, statusCode: statusCode);
    }
  }

  @override
  String toString() => 'NetworkException: $message (statusCode: $statusCode)';
}

class TimeoutException extends NetworkException {
  const TimeoutException({required super.message, super.statusCode});
}

class NoInternetException extends NetworkException {
  const NoInternetException({required super.message, super.statusCode});
}

class BadRequestException extends NetworkException {
  const BadRequestException({required super.message, super.statusCode});
}

class UnauthorizedException extends NetworkException {
  const UnauthorizedException({required super.message, super.statusCode});
}

class ForbiddenException extends NetworkException {
  const ForbiddenException({required super.message, super.statusCode});
}

class NotFoundException extends NetworkException {
  const NotFoundException({required super.message, super.statusCode});
}

class ServerException extends NetworkException {
  const ServerException({required super.message, super.statusCode});
}

class RequestCancelledException extends NetworkException {
  const RequestCancelledException({required super.message, super.statusCode});
}

class UnknownException extends NetworkException {
  const UnknownException({required super.message, super.statusCode});
}
