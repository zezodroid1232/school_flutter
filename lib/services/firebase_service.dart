import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyAkIdohq9muISla_pUvWZzJnk8Dq03R7QQ",
            authDomain: "fir-ide-7d022.firebaseapp.com",
            databaseURL: "https://fir-ide-7d022-default-rtdb.firebaseio.com",
            projectId: "fir-ide-7d022",
            storageBucket: "fir-ide-7d022.appspot.com",
            messagingSenderId: "884464757996",
            appId: "1:884464757996:web:937fbeb1d3c1a3df5d09c9",
            measurementId: "G-ZNM7K8J8KC",
          ),
        );
      }
    } catch (e) {
      debugPrint("Firebase initialization failed: $e");
    }
  }
}
