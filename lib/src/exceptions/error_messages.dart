class ErrorMessages {
  static const biometricNotAvailable = 'biometricNotAvailable';
  static const authFailed = 'authFailed';
  static const setupFailed = 'setupFailed';
  static const checkAvailability = 'checkAvailability';
  static const disableFailed = 'disableFailed';
  static const checkEnabled = 'checkEnabled';
  static const confirmUsing = 'confirmUsing';
  static const authReasonMessage = 'authReasonMessage';
  static const biometricIsNotEnabled = 'biometricIsNotEnabled';
  static const stopAuthenticationFailed = 'stopAuthenticationFailed';

  static const _errorMessages = {
    biometricNotAvailable: 'Biometric  is not supported on this device.',
    authFailed: 'Biometric authentication failed.',
    setupFailed: 'Failed to authenticate during Biometric  setup.',
    checkAvailability: 'Biometric scanner unavailable. Please log in using your password.',
    disableFailed: 'Failed to disable Biometric .',
    checkEnabled: 'Failed to check if Biometric  is enabled.',
    authReasonMessage: 'You can use your Biometric to confirm making payments through this app.',
    biometricIsNotEnabled: 'Biometric  is not enabled, please call enableBiometric() first.',
    stopAuthenticationFailed: 'Stop Authentication failed,',
  };

  static String getErrorMessage(String key) {
    return _errorMessages[key]!;
  }
}
