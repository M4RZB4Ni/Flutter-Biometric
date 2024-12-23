import 'package:biometric/src/exceptions/exceptions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthManager {
  BiometricAuthManager({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
    String? reasonMessage,
    bool? biometricOnly,
    bool? stickyAuth,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _reasonMessage = reasonMessage ?? ErrorMessages.getErrorMessage(ErrorMessages.authReasonMessage),
        _biometricOnly = biometricOnly,
        _stickyAuth = stickyAuth {
    _options = AuthenticationOptions(
      biometricOnly: _biometricOnly ?? false,
      stickyAuth: _stickyAuth ?? false,
    );
  }

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;
  final String _reasonMessage;
  final bool? _biometricOnly;
  final bool? _stickyAuth;
  static const _biometricEnabledKey = 'biometric_enabled';
  late AuthenticationOptions _options;

  /// Check if the device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return isDeviceSupported && canCheckBiometrics;
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.checkAvailability)}: $e');
    }
  }

  /// Enable biometric
  Future<bool> enableBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw BiometricAuthException(ErrorMessages.getErrorMessage(ErrorMessages.biometricNotAvailable));
      }
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: _reasonMessage,
        options: _options,
      );

      if (didAuthenticate) {
        await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
        return true;
      } else {
        throw BiometricAuthException(ErrorMessages.getErrorMessage(ErrorMessages.setupFailed));
      }
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.setupFailed)}: $e');
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        throw BiometricAuthException(ErrorMessages.getErrorMessage(ErrorMessages.biometricIsNotEnabled));
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: _reasonMessage,
        options: _options,
      );

      if (didAuthenticate) {
        return true;
      } else {
        throw BiometricAuthException(ErrorMessages.getErrorMessage(ErrorMessages.authFailed));
      }
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.authFailed)}: $e');
    }
  }

  /// Disable biometric
  Future<bool> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      return true;
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.disableFailed)}: $e');
    }
  }

  /// Check if biometric  is currently enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.checkEnabled)}: $e');
    }
  }
}
