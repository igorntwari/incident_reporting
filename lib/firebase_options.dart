// Generated from google-services.json / GoogleService-Info.plist for the
// Firebase project `campus-fix-c0edc` (equivalent to `flutterfire configure`).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => switch (defaultTargetPlatform) {
        TargetPlatform.android => android,
        TargetPlatform.iOS => ios,
        _ => throw UnsupportedError(
            'Campus Fix runs on Android and iOS only.',
          ),
      };

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyA7m1xtwdc37yW1T5JcE640NSGbmm2rl6k',
    appId: '1:307102479760:android:15f33cfe18f68db4e72f15',
    messagingSenderId: '307102479760',
    projectId: 'campus-fix-c0edc',
    storageBucket: 'campus-fix-c0edc.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyDdRprpwXdb2WHY8IJoHaY4jMpmHXJcIEI',
    appId: '1:307102479760:ios:9f07d705c1372a87e72f15',
    messagingSenderId: '307102479760',
    projectId: 'campus-fix-c0edc',
    storageBucket: 'campus-fix-c0edc.firebasestorage.app',
    iosBundleId: 'com.example.incidentReporting',
  );
}
