import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'FirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmvproflVqQ7ymn3di-6pJh02soSyIqqo',
    appId: '1:634639795131:web:06c0941abf49c68078fa9e',
    messagingSenderId: '634639795131',
    projectId: 'super-app-ditto',
    authDomain: 'super-app-ditto.firebaseapp.com',
    storageBucket: 'super-app-ditto.firebasestorage.app',
    measurementId: 'G-4ZLVXY0GL3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDhoSgtC9hn_Izinb1ToeB79Ix3_8DxBSo',
    appId: '1:634639795131:android:4dfd87255718ce4278fa9e',
    messagingSenderId: '634639795131',
    projectId: 'super-app-ditto',
    storageBucket: 'super-app-ditto.firebasestorage.app',
  );
}
