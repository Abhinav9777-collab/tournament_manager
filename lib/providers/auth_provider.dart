import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppAuthProvider with ChangeNotifier {
  String? _uid;
  String? _displayName;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _uid != null;
  String get uid => _uid ?? '';
  String get displayName => _displayName ?? 'User';

  AppAuthProvider() {
    _autoLoginCheck();
  }

  Future<void> _autoLoginCheck() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('app_session_uid') && prefs.containsKey('app_session_user')) {
      _uid = prefs.getString('app_session_uid');
      _displayName = prefs.getString('app_session_user');
      notifyListeners();
    }
  }

  Future<String?> signUp(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.length < 6) {
      return 'Password should be at least 6 characters.';
    }

    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userRegistryKey = 'user_reg_$cleanEmail';

    if (prefs.containsKey(userRegistryKey)) {
      _isLoading = false;
      notifyListeners();
      return 'Account already exists. Try logging in.';
    }

    final encryptedPassword = base64.encode(utf8.encode(password));
    final userPayload = {
      'uid': 'usr_${DateTime.now().millisecondsSinceEpoch}',
      'username': cleanEmail.split('@').first,
      'pwd': encryptedPassword
    };

    await prefs.setString(userRegistryKey, json.encode(userPayload));
    _isLoading = false;
    notifyListeners();
    return await logIn(cleanEmail, password);
  }

  Future<String?> logIn(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.isEmpty) return 'Fields cannot be blank.';

    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userRegistryKey = 'user_reg_$cleanEmail';

    if (!prefs.containsKey(userRegistryKey)) {
      _isLoading = false;
      notifyListeners();
      return 'Incorrect email or password parameters.';
    }

    final Map<String, dynamic> userPayload = json.decode(prefs.getString(userRegistryKey)!);
    final decodedPwd = utf8.decode(base64.decode(userPayload['pwd']));

    if (decodedPwd != password) {
      _isLoading = false;
      notifyListeners();
      return 'Incorrect email or password parameters.';
    }

    _uid = userPayload['uid'];
    _displayName = userPayload['username'];

    await prefs.setString('app_session_uid', _uid!);
    await prefs.setString('app_session_user', _displayName!);

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> logOut() async {
    _uid = null;
    _displayName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_session_uid');
    await prefs.remove('app_session_user');
    notifyListeners();
  }
}