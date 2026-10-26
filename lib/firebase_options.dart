import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDS7ksuMHujGgP1OY-PvKVqbugYnTG_nf8',
    appId: '1:391045193954:android:a1c43c245637be15463ebb',
    messagingSenderId: '391045193954',
    projectId: 'idf-project-26d52',
    storageBucket: 'idf-project-26d52.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQcvxZQS-gBk40vqnEz0ufdvSychpWQ5w',
    appId: '1:391045193954:ios:354afa23118050ce463ebb',
    messagingSenderId: '391045193954',
    projectId: 'idf-project-26d52',
    storageBucket: 'idf-project-26d52.firebasestorage.app',
    iosBundleId: 'com.azista.idf',
  );
}
