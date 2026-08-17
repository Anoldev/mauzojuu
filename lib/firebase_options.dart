// File generated manually from google-services.json
// Project: MauzoJuu (mauzojuu-62a66)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'MauzoJuu haisaidii web bado. Tumia Android.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions hazisaidiwi kwa platform hii.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1vpwSEpkDMiE2moCYnYbX_x2wIqynpDs',
    appId: '1:863611973822:android:6dec579671ee3ec4a8aeef',
    messagingSenderId: '863611973822',
    projectId: 'mauzojuu-62a66',
    storageBucket: 'mauzojuu-62a66.firebasestorage.app',
  );
}
