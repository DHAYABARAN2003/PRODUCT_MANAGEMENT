import 'package:product_management_app/core/network/network_exceptions.dart';

/// A generic result type for API calls.
/// Either [Success] or [Failure].
sealed class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T data) = Success<T>;
  factory ApiResult.failure(NetworkException exception) = Failure<T>;

  /// Fold over success/failure cases
  R when<R>({
    required R Function(T data) success,
    required R Function(NetworkException exception) failure,
  }) {
    return switch (this) {
      Success<T>(data: final d) => success(d),
      Failure<T>(exception: final e) => failure(e),
    };
  }
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final NetworkException exception;
  const Failure(this.exception);
}
