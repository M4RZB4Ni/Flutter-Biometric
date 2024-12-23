class BiometricAuthException implements Exception {
  BiometricAuthException(this.message);

  final String message;

  @override
  String toString() => 'BiometricAuthException: $message';
}
