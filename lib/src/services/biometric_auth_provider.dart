import 'package:biometric/src/exceptions/exceptions.dart';
import 'package:biometric/src/services/biometric_auth_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:meta/meta.dart';

class BiometricAuthProvider {
  BiometricAuthProvider({
    String? reasonMessage,
    bool? biometricOnly,
    bool? stickyAuth,
    String? lockOut,
    String? goToSettingsButtonText,
    String? goToSettingsDescription,
    String? cancelButtonText,
    String? localizedFallbackTitle,
    @visibleForTesting
    FlutterSecureStorage? secureStorage,
    @visibleForTesting
    LocalAuthentication? localAuth,
  }) {
    _biometricAuthManager = BiometricAuthManager(
      /// Used when the application goes into background for any reason while the
      /// authentication is in progress. Due to security reasons, the
      /// authentication has to be stopped at that time. If stickyAuth is set to
      /// true, authentication resumes when the app is resumed. If it is set to
      /// false (default), then as soon as app is paused a failure message is sent
      /// back to Dart and it is up to the client app to restart authentication or
      /// do something else.
      stickyAuth: stickyAuth,
      /// Prevent authentications from using non-biometric local authentication
      /// such as pin, passcode, or pattern.
      biometricOnly: biometricOnly,
      /// the message to show to user while prompting them
      /// for authentication. If you avoid passing it, default message that is:
      /// "You can use your Biometric to confirm making payments through this app."
      /// shown to user.
      reasonMessage: reasonMessage,
      /// Message shown on a button that the user can click to leave the current
      /// dialog.
      /// Maximum 30 characters.
      cancelButtonText: cancelButtonText,
      /// Message shown on a button that the user can click to go to settings pages
      /// from the current dialog.
      /// Maximum 30 characters.
      goToSettingsButtonText: goToSettingsButtonText,
      /// Message advising the user to go to the settings and configure Biometrics
      /// for their device.
      goToSettingsDescription: goToSettingsDescription,
      /// The localized title for the fallback button in the dialog presented to
      /// the user during authentication.
      localizedFallbackTitle: localizedFallbackTitle,
      /// Message advising the user to re-enable biometrics on their device.
      lockOut: lockOut,
      localAuth: localAuth,
      secureStorage: secureStorage,
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
      rethrow;
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
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }

  /// Checks if biometric  is currently enabled.
  Future<bool> isBiometricEnabled() async {
    try {
      return await _biometricAuthManager.isBiometricEnabled();
    } catch (e) {
      rethrow;
    }
  }

  /// Cancels any in-progress authentication, returning true if auth was
  /// cancelled successfully.
  ///
  /// This API is not supported by all platforms.
  /// Returns false if there was some error, no authentication in progress,
  /// or the current platform lacks support.
  Future<bool> stopAuthentication() async {
    try {
      return await _biometricAuthManager.stopAuthentication();
    } catch (e) {
      rethrow;
    }
  }
}
