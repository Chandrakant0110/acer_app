// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBQds2yeD5wEj-qRTfX2WYy-xQN_3be3A',
    appId: '1:884348080592:web:83b62507aa40ce591829d5',
    messagingSenderId: '884348080592',
    projectId: 'acer-app-651fc',
    authDomain: 'acer-app-651fc.firebaseapp.com',
    storageBucket: 'acer-app-651fc.firebasestorage.app',
    measurementId: 'G-5BVXHVWWBP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYaSzRMGby8safidOBh7wRXteRdXHZgmw',
    appId: '1:884348080592:android:2e01412b0994742b1829d5',
    messagingSenderId: '884348080592',
    projectId: 'acer-app-651fc',
    storageBucket: 'acer-app-651fc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1ss3bdGv6lR6hemClgPqeLgxHy-O0V48',
    appId: '1:884348080592:ios:060005dffbbd907a1829d5',
    messagingSenderId: '884348080592',
    projectId: 'acer-app-651fc',
    storageBucket: 'acer-app-651fc.firebasestorage.app',
    iosBundleId: 'com.example.acerApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA1ss3bdGv6lR6hemClgPqeLgxHy-O0V48',
    appId: '1:884348080592:ios:060005dffbbd907a1829d5',
    messagingSenderId: '884348080592',
    projectId: 'acer-app-651fc',
    storageBucket: 'acer-app-651fc.firebasestorage.app',
    iosBundleId: 'com.example.acerApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCBQds2yeD5wEj-qRTfX2WYy-xQN_3be3A',
    appId: '1:884348080592:web:ee1dfe33031aa67d1829d5',
    messagingSenderId: '884348080592',
    projectId: 'acer-app-651fc',
    authDomain: 'acer-app-651fc.firebaseapp.com',
    storageBucket: 'acer-app-651fc.firebasestorage.app',
    measurementId: 'G-46DEST1WBH',
  );
}
