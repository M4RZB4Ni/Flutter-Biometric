# Biometric Authentication Module

A robust biometric authentication module built for Flutter applications,
providing an easy and clean way to handle biometric-based authentication workflows.

## Overview

This module simplifies the integration of **Biometric Authentication** using local device
biometrics (FaceID, Fingerprint, etc.). It provides services for enabling, disabling, and
authenticating using biometrics, with proper exception handling and extensibility.

On supported devices, this includes authentication with biometrics such as
fingerprint or facial recognition.

|             | Android   | iOS   | macOS  | Windows     |
|-------------|-----------|-------|--------|-------------|
| **Support** | SDK 16+\* | 12.0+ | 10.14+ | Windows 10+ |

---

## Features

- **Check Biometric Availability**: Verify if biometrics are supported on the device.
- **Enable Biometric**: Set up biometric authentication.
- **Authenticate with Biometrics**: Perform secure biometric .
- **Disable Biometric**: Remove biometric authentication settings.
- **Error Handling**: Consistent exception management for better error reporting.
- **Message Handling**: Pass corresponding messages that user see during usage.
---

## Directory Structure

The module follows a clean and modular architecture:

```
lib/
└── src/
    ├── exceptions/
    │   ├── error_messages.dart           # Contains error message constants.
    │   ├── exceptions.dart               # General exception exports.
    │   └── biometric_auth_exception.dart # Custom exception for biometrics.
    │
    ├── messages/
    │   ├── messages.dart                 # General messages exports.
    │   └── biometric_auth_messages.dart  # Biometric-specific messages.
    │       
    ├── services/
    │   ├── biometric_auth_manager.dart   # Handles biometric authentication logic.
    │   └── biometric_auth_provider.dart  # High-level provider for biometric features.
    │
    └── biometric.dart                    # Entry point file to export module classes.

test/
└── mocks/
    ├── mocks.dart                        # Manual mock dependencies.
    └── mocks.mocks.dart                  # Generated mocks via Mockito.
    
└── services/
    ├── biometric_auth_provider_test.dart # Tests for BiometricAuthProvider.
    └── biometric_auth_manager_test.dart  # Tests for BiometricAuthManager.
```

---

## Installation

1. Add this module in target's `pubspec.yaml`:

```yaml
biometric:
  path: path to this module
```
## iOS Integration

Note that this plugin works with both Touch ID and Face ID. However, to use the latter,
you need to also add:

## Android Integration

\* The plugin will build and run on SDK 16+, but `isDeviceSupported()` will
always return false before SDK 23 (Android 6.0).

### Activity Changes

Note that `local_auth` requires the use of a `FragmentActivity` instead of an
`Activity`. To update your application:

* If you are using `FlutterActivity` directly, change it to
  `FlutterFragmentActivity` in your `AndroidManifest.xml`.
* If you are using a custom activity, update your `MainActivity.java`:

    ```java
    import io.flutter.embedding.android.FlutterFragmentActivity;

    public class MainActivity extends FlutterFragmentActivity {
        // ...
    }
    ```

  or MainActivity.kt:

    ```kotlin
    import io.flutter.embedding.android.FlutterFragmentActivity

    class MainActivity: FlutterFragmentActivity() {
        // ...
    }
    ```

  to inherit from `FlutterFragmentActivity`.

### Permissions

Update your project's `AndroidManifest.xml` file to include the
`USE_BIOMETRIC` permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="com.example.app">
  <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<manifest>
```

### Compatibility

On Android, you can check only for existence of fingerprint hardware prior
to API 29 (Android Q). Therefore, if you would like to support other biometrics
types (such as face scanning) and you want to support SDKs lower than Q,
_do not_ call `getAvailableBiometrics`. Simply call `authenticate` with `biometricOnly: true`.
This will return an error if there was no hardware available.

#### Android theme

Your `LaunchTheme`'s parent must be a valid `Theme.AppCompat` theme to prevent
crashes on Android 8 and below. For example, use `Theme.AppCompat.DayNight` to
enable light/dark modes for the biometric dialog. To do that go to
`android/app/src/main/res/values/styles.xml` and look for the style with name
`LaunchTheme`. Then change the parent for that style as follows:

```xml
...
<resources>
  <style name="LaunchTheme" parent="Theme.AppCompat.DayNight">
    ...
  </style>
  ...
</resources>
...
```

If you don't have a `styles.xml` file for your Android project you can set up
the Android theme directly in `android/app/src/main/AndroidManifest.xml`:

```xml
...
	<application
		...
		<activity
			...
			android:theme="@style/Theme.AppCompat.DayNight"
			...
		>
		</activity>
	</application>
...
```

```xml
<key>NSFaceIDUsageDescription</key>
<string>Why is my app authenticating using face id?</string>
```

to your Info.plist file. Failure to do so results in a dialog that tells the user your
app has not been updated to use Face ID.

2. Generate mocks for unit tests using `mockito`:

```bash
flutter pub run build_runner build
```

---

## Android Integration

* The plugin will build and run on SDK 16+, but isDeviceSupported() will always return false before
  SDK 23 (Android 6.0).

1. Activity Changes
   Note that local_auth requires the use of a FragmentActivity instead of an Activity. To update
   your application:

If you are using FlutterActivity directly, change it to FlutterFragmentActivity in your
AndroidManifest.xml.

If you are using a custom activity, update your MainActivity.java:

```dart
import
io.flutter.embedding.android.FlutterFragmentActivity;

public

class MainActivity extends FlutterFragmentActivity {
// ...
}
or
MainActivity.kt:

import
io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity:

FlutterFragmentActivity() {
// ...
}
```

to inherit from FlutterFragmentActivity.

2. Permissions
   Update your project's AndroidManifest.xml file to include the USE_BIOMETRIC permissions:

```<manifest xmlns:android="http://schemas.android.com/apk/res/android"
package="com.example.app">
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<manifest>
```

3. Compatibility
   On Android, you can check only for existence of fingerprint hardware prior to API 29 (Android Q).

---

## Usage

### 1. **Import the Module**

```dart
import 'package:biometric/src/services/biometric_auth_provider.dart';
```

### 2. **Initialize BiometricAuthProvider**

```dart

final biometricAuthProvider = BiometricAuthProvider(
  localAuth: LocalAuthentication(),
  secureStorage: FlutterSecureStorage(),
  reasonMessage: 'Authenticate to proceed',
  biometricOnly: true,
  stickyAuth: false,
);
```

### 3. **Check Biometric Availability**

```dart
try {
final isAvailable = await biometricAuthProvider.isBiometricAvailable();
print('Biometrics available: $isAvailable');
} catch (e) {
print('Error: $e');
}
```

### 4. **Enable Biometric **

```dart
try {
final success = await biometricAuthProvider.enableBiometric();
print('Biometric  enabled: $success');
} catch (e) {
print('Error: $e');
}
```

### 5. **Authenticate with Biometrics**

```dart
try {
final isAuthenticated = await biometricAuthProvider.authenticate();
print('User authenticated: $isAuthenticated');
} catch (e) {
print('Authentication failed: $e');
}
```

### 6. **Disable Biometric **

```dart
try {
final success = await biometricAuthProvider.disableBiometric();
print('Biometric  disabled: $success');
} catch (e) {
print('Error: $e');
}
```

---

## Error Handling

All exceptions related to biometric operations are wrapped in the `BiometricAuthException` class.

Example:

```dart
try {
await biometricAuthProvider.isBiometricAvailable();
} catch (e) {
if (e is BiometricAuthException) {
print('Handled Biometric Error: ${e.message}');
} else {
print('Unhandled Error: $e');
}
}
```

Error messages are centralized in `ErrorMessages` for consistent reporting.

---

## Message Handling

Corresponding messages which user see during usage are handling by `BiometricAuthMessages` class.
Developer can pass parameters through `BiometricAuthProvider` class.

Example:

```dart
class BiometricAuthProvider {
  BiometricAuthProvider({
  String? lockOut,
  String? goToSettingsButtonText,
  String? goToSettingsDescription,
  String? cancelButtonText,
  String? localizedFallbackTitle,
}) {
    _biometricAuthManager = BiometricAuthManager(

      cancelButtonText: cancelButtonText,
      goToSettingsButtonText: goToSettingsButtonText,
      goToSettingsDescription: goToSettingsDescription,
      localizedFallbackTitle: localizedFallbackTitle,
      lockOut: lockOut,
    );
  }}
```

---

## Testing

Unit tests are provided for both `BiometricAuthManager` and `BiometricAuthProvider`:

- **Mocks**: Generated using Mockito for `LocalAuthentication` and `FlutterSecureStorage`.
- **Example Test**:

```dart
test
('should return true if biometrics are available', () async {
when(mockManager.isBiometricAvailable()).thenAnswer((_) async => true);

final result = await provider.isBiometricAvailable();

expect(result, true);
verify(mockManager.isBiometricAvailable()).called(1);
});
```

To run tests:

```bash
flutter test
```

---

## Contact

For support or questions, reach out to Amin (Head of the Mobile tech lead) or Hamid (developer).

---