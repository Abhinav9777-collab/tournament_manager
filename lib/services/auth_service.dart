import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🚀 Google Apps Script Web App URL for Free Unlimited OTP
  static const String _googleScriptUrl = "https://script.google.com/macros/s/AKfycbyDq4d8TALsyRYfoBK803t_MDfZ_pTxfK5yaWm-b7uiVqSTDKNaJW4UORUAqOf2ikSh/exec";

  User? get currentUser => _auth.currentUser;

  // Helper to turn a plain username into a valid email format for Firebase
  String _processUsername(String username) {
    return "${username.trim().toLowerCase()}@tournament.com";
  }

  // 📧 Send Unlimited Free Email OTP using Google Apps Script
  Future<bool> sendFreeOTP(String recipientEmail, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse(_googleScriptUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": recipientEmail.trim(),
          "otp": otpCode.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        return result['status'] == 'SUCCESS';
      } else {
        print("Failed to send OTP. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error sending OTP via Google Apps Script: $e");
      return false;
    }
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