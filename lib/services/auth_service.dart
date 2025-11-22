import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final snapshot = await _dbRef.child('users').child(uid).get();
      if (snapshot.exists) {
        _currentUser = UserModel.fromMap(
          Map<String, dynamic>.from(snapshot.value as Map),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<void> registerUser(UserModel user) async {
    try {
      await _dbRef.child('users').child(user.uid).set(user.toMap());
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      debugPrint("Error registering user: $e");
    }
  }

  // Check if user exists in DB
  Future<bool> userExists(String uid) async {
    final snapshot = await _dbRef.child('users').child(uid).get();
    return snapshot.exists;
  }
}
