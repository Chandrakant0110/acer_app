import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricAuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types (fingerprint, face, etc.)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate user using biometrics or device credentials
  static Future<bool> authenticateUser({
    required String reason,
    bool allowFallback = true,
  }) async {
    try {
      // Check if any authentication method is available
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      // If device doesn't support any authentication, return false
      if (!isDeviceSupported) {
        return false;
      }

      // Try to authenticate with biometrics first, then fallback to device credentials
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // This is crucial - allows PIN/Password fallback
          stickyAuth: true,
          sensitiveTransaction: false, // Set to false to avoid issues
          useErrorDialogs: true, // Show system error dialogs
        ),
      );

      return didAuthenticate;
    } catch (e) {
      // Handle specific error cases with better logging
      print('Authentication error: $e');
      if (e is PlatformException) {
        switch (e.code) {
          case auth_error.notAvailable:
            print('Authentication not available');
            return false;
          case auth_error.notEnrolled:
            print('No biometrics enrolled, but device credentials should still work');
            // Try again with device credentials only
            try {
              return await _localAuth.authenticate(
                localizedReason: reason,
                options: const AuthenticationOptions(
                  biometricOnly: false,
                  useErrorDialogs: true,
                ),
              );
            } catch (e2) {
              print('Device credentials also failed: $e2');
              return false;
            }
          case auth_error.lockedOut:
          case auth_error.permanentlyLockedOut:
            print('Authentication locked out');
            return false;
          default:
            print('Other authentication error: ${e.code}');
            return false;
        }
      }
      return false;
    }
  }

  /// Get authentication description based on available biometrics
  static Future<String> getAuthenticationDescription() async {
    final availableBiometrics = await getAvailableBiometrics();
    
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Use Face ID, fingerprint, or device password to continue';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Use fingerprint or device password to continue';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Use iris scan or device password to continue';
    } else {
      return 'Use device password or PIN to continue';
    }
  }

  /// Show authentication dialog with custom message
  static Future<bool> showAuthenticationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String reason,
  }) async {
    // Check device support first
    final bool isDeviceSupported = await _localAuth.isDeviceSupported();
    if (!isDeviceSupported) {
      // Show error dialog if device doesn't support authentication
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Authentication Not Available'),
          content: const Text(
            'Your device does not support biometric authentication or device lock. Please set up a screen lock (PIN, pattern, or password) in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }

    // First show explanation dialog
    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available authentication methods:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<BiometricType>>(
                    future: getAvailableBiometrics(),
                    builder: (context, snapshot) {
                      final biometrics = snapshot.data ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (biometrics.contains(BiometricType.fingerprint))
                            const Text('• Fingerprint'),
                          if (biometrics.contains(BiometricType.face))
                            const Text('• Face ID'),
                          if (biometrics.contains(BiometricType.iris))
                            const Text('• Iris scan'),
                          const Text('• Device PIN/Password/Pattern'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Authenticate'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return false;

    // Then perform biometric authentication
    return await authenticateUser(reason: reason);
  }
} 