// Placeholder Firebase options file.
// If you run `flutterfire configure` this file will be replaced with
// a generated `DefaultFirebaseOptions` implementation including web options.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Manual FirebaseOptions generated from `android/app/google-services.json`.
/// This file contains Android options only. For web or full platform support
/// run `flutterfire configure` to regenerate a complete `firebase_options.dart`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not configured for this platform.\n'
      'Run `flutterfire configure` to generate platform specific options.'
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAboWLCQaNfOGTeSWZrxMZf4l_wG0kggzo',
    appId: '1:147086924308:android:815b0f88331bb84c4fe501',
    messagingSenderId: '147086924308',
    projectId: 'device-streaming-bc8de7d8',
    storageBucket: 'device-streaming-bc8de7d8.firebasestorage.app',
  );
}
