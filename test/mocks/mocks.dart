import 'package:biometric/src/messages/messages.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  FlutterSecureStorage,
  LocalAuthentication,
  BiometricAuthMessages,
])
void main() {}
