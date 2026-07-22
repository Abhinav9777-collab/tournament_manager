import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Helper to turn a plain username into a valid email format for Firebase
  String _processUsername(String username) {
    return "${username.trim().toLowerCase()}@tournament.com";
  }

  Future<UserCredential> signUp(String username, String password) async {
    String email = _processUsername(username);
    UserCredential creds = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (creds.user != null) {
      await _db.collection('users').doc(creds.user!.uid).set({
        'uid': creds.user!.uid,
        'username': username.trim(),
        'displayName': username.trim(),
        'role': 'host',
      });
    }
    return creds;
  }

  Future<UserCredential> login(String username, String password) async {
    String email = _processUsername(username);
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String username) async {
    String email = _processUsername(username);
    await _auth.sendPasswordResetEmail(email: email);
  }
}