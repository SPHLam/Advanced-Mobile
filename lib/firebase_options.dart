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
    apiKey: 'AIzaSyB2TwEleDoPhqqTxLpMNZR9ZjrrfphYt4M',
    appId: '1:230147337499:web:07de211eb4e406b1b937be',
    messagingSenderId: '230147337499',
    projectId: 'project-ai-chat-feb94',
    authDomain: 'project-ai-chat-feb94.firebaseapp.com',
    storageBucket: 'project-ai-chat-feb94.firebasestorage.app',
    measurementId: 'G-KJKRD3MW1Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCs-sZ__tG-sLvFz81bRhpauNucEH1Wqus',
    appId: '1:230147337499:android:d932ed82901b3b62b937be',
    messagingSenderId: '230147337499',
    projectId: 'project-ai-chat-feb94',
    storageBucket: 'project-ai-chat-feb94.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCogxyGLchhEWVM9gbqq9HTouxGqKr6CS0',
    appId: '1:230147337499:ios:9cfddbcb582da8a1b937be',
    messagingSenderId: '230147337499',
    projectId: 'project-ai-chat-feb94',
    storageBucket: 'project-ai-chat-feb94.firebasestorage.app',
    iosBundleId: 'com.example.projectAiChat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCogxyGLchhEWVM9gbqq9HTouxGqKr6CS0',
    appId: '1:230147337499:ios:9cfddbcb582da8a1b937be',
    messagingSenderId: '230147337499',
    projectId: 'project-ai-chat-feb94',
    storageBucket: 'project-ai-chat-feb94.firebasestorage.app',
    iosBundleId: 'com.example.projectAiChat',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB2TwEleDoPhqqTxLpMNZR9ZjrrfphYt4M',
    appId: '1:230147337499:web:52d5b2f1471c4036b937be',
    messagingSenderId: '230147337499',
    projectId: 'project-ai-chat-feb94',
    authDomain: 'project-ai-chat-feb94.firebaseapp.com',
    storageBucket: 'project-ai-chat-feb94.firebasestorage.app',
    measurementId: 'G-89SMXJLNEY',
  );
}
