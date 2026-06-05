/// Custom failure class for use-case level errors.
class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => 'Failure: $message';
}
