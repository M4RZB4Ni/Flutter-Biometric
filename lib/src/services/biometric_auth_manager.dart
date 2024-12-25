import 'package:biometric/src/exceptions/exceptions.dart';
import 'package:biometric/src/messages/biometric_auth_messages.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthManager {
  BiometricAuthManager({
    String? reasonMessage,
    bool? biometricOnly,
    bool? stickyAuth,
    String? lockOut,
    String? goToSettingsButtonText,
    String? goToSettingsDescription,
    String? cancelButtonText,
    String? localizedFallbackTitle,
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _reasonMessage = reasonMessage ?? ErrorMessages.getErrorMessage(ErrorMessages.authReasonMessage),
        _biometricOnly = biometricOnly,
        _localAuth = localAuth ?? LocalAuthentication(),
        _lockOut = lockOut,
        _goToSettingsButtonText = goToSettingsButtonText,
        _goToSettingsDescription = goToSettingsDescription,
        _cancelButtonText = cancelButtonText,
        _localizedFallbackTitle = localizedFallbackTitle,
        _stickyAuth = stickyAuth {
    _options = AuthenticationOptions(
      biometricOnly: _biometricOnly ?? false,
      stickyAuth: _stickyAuth ?? false,
    );
    _authMessages = BiometricAuthMessages(
      lockOut: _lockOut,
      goToSettingsButton: _goToSettingsButtonText,
      goToSettingsDescription: _goToSettingsDescription,
      cancelButton: _cancelButtonText,
      localizedFallbackTitle: _localizedFallbackTitle,
    );
  }

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;
  final String _reasonMessage;
  final bool? _biometricOnly;
  final bool? _stickyAuth;
  static const _biometricEnabledKey = 'biometric_enabled';
  late AuthenticationOptions _options;
  late BiometricAuthMessages _authMessages;

  /// Message advising the user to re-enable biometrics on their device.
  final String? _lockOut;

  /// Message shown on a button that the user can click to go to settings pages
  /// from the current dialog.
  /// Maximum 30 characters.
  final String? _goToSettingsButtonText;

  /// Message advising the user to go to the settings and configure Biometrics
  /// for their device.
  final String? _goToSettingsDescription;

  /// Message shown on a button that the user can click to leave the current
  /// dialog.
  /// Maximum 30 characters.
  final String? _cancelButtonText;

  /// The localized title for the fallback button in the dialog presented to
  /// the user during authentication.
  final String? _localizedFallbackTitle;

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
        authMessages: [_authMessages],
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
        authMessages: [_authMessages],
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

  /// Cancels any in-progress authentication, returning true if auth was
  /// cancelled successfully.
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      throw BiometricAuthException('${ErrorMessages.getErrorMessage(ErrorMessages.stopAuthenticationFailed)}: $e');
    }
  }
}
