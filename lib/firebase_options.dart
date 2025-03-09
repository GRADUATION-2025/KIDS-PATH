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
    apiKey: 'AIzaSyC6H3yTsX-W5ZCdu-JPuJ_EetRcPK-OEZ0',
    appId: '1:897044060897:web:a996fa088d7e31f454f5a0',
    messagingSenderId: '897044060897',
    projectId: 'kids-path-58c66',
    authDomain: 'kids-path-58c66.firebaseapp.com',
    storageBucket: 'kids-path-58c66.firebasestorage.app',
    measurementId: 'G-CRGB40NG7W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB1PGni3rvHfT9iy2tGHpF2VrIlkyeDN68',
    appId: '1:897044060897:android:01a09ecddf6a488454f5a0',
    messagingSenderId: '897044060897',
    projectId: 'kids-path-58c66',
    storageBucket: 'kids-path-58c66.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCpmpAGWtp98btMeLN4GlWhsYtylo9ciOE',
    appId: '1:897044060897:ios:11320b8913eaa89654f5a0',
    messagingSenderId: '897044060897',
    projectId: 'kids-path-58c66',
    storageBucket: 'kids-path-58c66.firebasestorage.app',
    iosBundleId: 'com.example.kidspath',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCpmpAGWtp98btMeLN4GlWhsYtylo9ciOE',
    appId: '1:897044060897:ios:11320b8913eaa89654f5a0',
    messagingSenderId: '897044060897',
    projectId: 'kids-path-58c66',
    storageBucket: 'kids-path-58c66.firebasestorage.app',
    iosBundleId: 'com.example.kidspath',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC6H3yTsX-W5ZCdu-JPuJ_EetRcPK-OEZ0',
    appId: '1:897044060897:web:4abc33564446682454f5a0',
    messagingSenderId: '897044060897',
    projectId: 'kids-path-58c66',
    authDomain: 'kids-path-58c66.firebaseapp.com',
    storageBucket: 'kids-path-58c66.firebasestorage.app',
    measurementId: 'G-1NJ2GF186G',
  );
}
