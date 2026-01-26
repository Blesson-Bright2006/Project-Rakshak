// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCGhfUMvSwQvxGr8zjlW0i0hoAyDfF6QU',
    appId: '1:98589889380:android:4990367ca05fe1db306071',
    messagingSenderId: '98589889380',
    projectId: 'project-rakshak-7c370',
    storageBucket: 'project-rakshak-7c370.firebasestorage.app',
  );
}
