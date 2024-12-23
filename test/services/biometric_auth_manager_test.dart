import 'package:biometric/src/exceptions/biometric_auth_exception.dart';
import 'package:biometric/src/services/biometric_auth_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockLocalAuthentication mockLocalAuth;
  late MockFlutterSecureStorage mockSecureStorage;
  late BiometricAuthManager biometricAuthManager;

  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    mockSecureStorage = MockFlutterSecureStorage();
    biometricAuthManager = BiometricAuthManager(
      localAuth: mockLocalAuth,
      secureStorage: mockSecureStorage,
      lockOut: 'lockOut',
      localizedFallbackTitle: 'localizedFallbackTitle',
      goToSettingsDescription: 'goToSettingsDescription',
      goToSettingsButtonText: 'goToSettingsButtonText',
      cancelButtonText: 'cancelButtonText',
    );
  });

  group('BiometricAuthManager', () {
    test('should return true if biometrics are available', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);

      final result = await biometricAuthManager.isBiometricAvailable();

      expect(result, true);
    });

    test('should throw exception if biometrics are not available', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

      expect(
        biometricAuthManager.isBiometricAvailable(),
        throwsA(isA<BiometricAuthException>()),
      );
    });

    test('should enable biometric successfully', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
        authMessages: anyNamed('authMessages'),
      )).thenAnswer((_) async => true);

      await biometricAuthManager.enableBiometric();

      verify(mockSecureStorage.write(
        key: 'biometric_enabled',
        value: 'true',
      )).called(1);
    });

    test('should throw exception if authentication fails during setup', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
        authMessages: anyNamed('authMessages'),
      )).thenAnswer((_) async => false);

      expect(
        biometricAuthManager.enableBiometric(),
        throwsA(isA<BiometricAuthException>()),
      );
    });

    test('should authenticate user successfully', () async {
      when(mockSecureStorage.read(key: 'biometric_enabled')).thenAnswer((_) async => 'true');
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
        authMessages: anyNamed('authMessages'),
      )).thenAnswer((_) async => true);

      final result = await biometricAuthManager.authenticateWithBiometrics();

      expect(result, true);
    });

    test('should throw exception if biometric  is disabled', () async {
      when(mockSecureStorage.read(key: 'biometric_enabled')).thenAnswer((_) async => null);

      expect(
        biometricAuthManager.authenticateWithBiometrics(),
        throwsA(isA<BiometricAuthException>()),
      );
    });

    test('should disable biometric  successfully', () async {
      await biometricAuthManager.disableBiometric();

      verify(mockSecureStorage.delete(key: 'biometric_enabled')).called(1);
    });
  });
}
