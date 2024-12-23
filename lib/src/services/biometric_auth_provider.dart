import 'package:biometric/src/exceptions/exceptions.dart';
import 'package:biometric/src/services/biometric_auth_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthProvider {
  BiometricAuthProvider({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
    String? reasonMessage,
    bool? biometricOnly,
    bool? stickyAuth,
    String? lockOut,
    String? goToSettingsButtonText,
    String? goToSettingsDescription,
    String? cancelButtonText,
    String? localizedFallbackTitle,
  }) {
    _biometricAuthManager = BiometricAuthManager(
      stickyAuth: stickyAuth,
      biometricOnly: biometricOnly,
      localAuth: localAuth,
      secureStorage: secureStorage,
      reasonMessage: reasonMessage,
      cancelButtonText: cancelButtonText,
      goToSettingsButtonText: goToSettingsButtonText,
      goToSettingsDescription: goToSettingsDescription,
      localizedFallbackTitle: localizedFallbackTitle,
      lockOut: lockOut,
    );
  }

  /// Biometric authentication manager instance.
  late BiometricAuthManager _biometricAuthManager;

  /// Checks if biometric authentication is available on the device.
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _biometricAuthManager.isBiometricAvailable();
      if (!isAvailable) {
        throw BiometricAuthException(ErrorMessages.getErrorMessage(ErrorMessages.biometricNotAvailable));
      }
      return isAvailable;
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.checkAvailability)}: $e');
    }
  }

  /// Enables biometric.
  Future<bool> enableBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw BiometricAuthException(ErrorMessages.getErrorMessage(ErrorMessages.biometricNotAvailable));
      }

      final success = await _biometricAuthManager.enableBiometric();
      if (!success) {
        throw BiometricAuthException(ErrorMessages.getErrorMessage(ErrorMessages.setupFailed));
      }
      return success;
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.setupFailed)}: $e');
    }
  }

  /// Authenticates the user using biometrics.
  Future<bool> authenticate() async {
    try {
      final isEnabled = await _biometricAuthManager.isBiometricEnabled();
      if (!isEnabled) {
        throw BiometricAuthException(ErrorMessages.getErrorMessage(ErrorMessages.biometricIsNotEnabled));
      }

      final success = await _biometricAuthManager.authenticateWithBiometrics();
      if (!success) {
        throw BiometricAuthException(ErrorMessages.getErrorMessage(ErrorMessages.authFailed));
      }
      return success;
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.authFailed)}: $e');
    }
  }

  /// Disables biometric .
  Future<bool> disableBiometric({bool? isOtpAuthenticate}) async {
    try {
      if (isOtpAuthenticate == true) {
        return await _biometricAuthManager.disableBiometric();
      } else {
        if (await authenticate()) {
          return await _biometricAuthManager.disableBiometric();
        }
        return false;
      }
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.disableFailed)}: $e');
    }
  }

  /// Checks if biometric  is currently enabled.
  Future<bool> isBiometricEnabled() async {
    try {
      return await _biometricAuthManager.isBiometricEnabled();
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.checkEnabled)}: $e');
    }
  }
}
