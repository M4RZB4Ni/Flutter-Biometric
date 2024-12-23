import 'package:biometric/src/exceptions/exceptions.dart';
import 'package:biometric/src/services/biometric_auth_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockLocalAuthentication mockLocalAuth;
  late MockFlutterSecureStorage mockSecureStorage;
  late BiometricAuthProvider provider;

  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    mockSecureStorage = MockFlutterSecureStorage();

    provider = BiometricAuthProvider(
      localAuth: mockLocalAuth,
      secureStorage: mockSecureStorage,
      lockOut: 'lockOut',
      localizedFallbackTitle: 'localizedFallbackTitle',
      goToSettingsDescription: 'goToSettingsDescription',
      goToSettingsButtonText: 'goToSettingsButtonText',
      cancelButtonText: 'cancelButtonText',
    );
  });

  group('BiometricAuthProvider', () {
    test('should return true if biometrics are available', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);

      final result = await provider.isBiometricAvailable();

      expect(result, true);
      verify(mockLocalAuth.isDeviceSupported()).called(1);
      verify(mockLocalAuth.canCheckBiometrics).called(1);
    });

    test('should throw exception if biometrics are not available', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

      expect(
        provider.isBiometricAvailable(),
        throwsA(isA<BiometricAuthException>()),
      );
      verify(mockLocalAuth.isDeviceSupported()).called(1);
    });

    test('should enable biometric  successfully', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
        authMessages: anyNamed('authMessages'),
      )).thenAnswer((_) async => true);

      when(mockSecureStorage.write(
        key: 'biometric_enabled',
        value: 'true',
      )).thenAnswer((_) async {});

      final result = await provider.enableBiometric();

      expect(result, true);
      verify(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
        authMessages: anyNamed('authMessages'),
      )).called(1);
      verify(mockSecureStorage.write(
        key: 'biometric_enabled',
        value: 'true',
      )).called(1);
    });

    test('should throw exception if biometric authentication fails during enable', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
        authMessages: anyNamed('authMessages'),
      )).thenAnswer((_) async => false);

      expect(
        provider.enableBiometric(),
        throwsA(isA<BiometricAuthException>()),
      );
    });

    test('should disable biometric  successfully', () async {
      when(mockSecureStorage.delete(key: 'biometric_enabled')).thenAnswer((_) async {});

      final result = await provider.disableBiometric(isOtpAuthenticate: true);

      expect(result, true);
      verify(mockSecureStorage.delete(key: 'biometric_enabled')).called(1);
    });

    test('should throw exception if disable biometric  fails', () async {
      when(mockSecureStorage.delete(key: 'biometric_enabled')).thenThrow(Exception('Storage error'));

      expect(
        provider.disableBiometric(isOtpAuthenticate: true),
        throwsA(isA<BiometricAuthException>()),
      );
      verify(mockSecureStorage.delete(key: 'biometric_enabled')).called(1);
    });

    test('should authenticate user successfully', () async {
      when(mockSecureStorage.read(key: 'biometric_enabled')).thenAnswer((_) async => 'true');

      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
        authMessages: anyNamed('authMessages'),
      )).thenAnswer((_) async => true);

      final result = await provider.authenticate();

      expect(result, true);
    });

    test('should throw exception if biometric  is not enabled', () async {
      when(mockSecureStorage.read(key: 'biometric_enabled')).thenAnswer((_) async => null);

      expect(
        provider.authenticate(),
        throwsA(isA<BiometricAuthException>()),
      );
      verify(mockSecureStorage.read(key: 'biometric_enabled')).called(1);
    });
  });
}
