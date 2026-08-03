import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tournament_provider.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onSignupSuccess;
  final VoidCallback onNavigateToLogin;

  const SignupScreen({
    super.key,
    required this.onSignupSuccess,
    required this.onNavigateToLogin,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 🚀 Direct Fraud-Proof Account Registration Logic
  void _handleRegistration(TournamentProvider provider) {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty) {
      _showSnackBar("Please enter your name/username!", Colors.orange);
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar("Please enter a valid email address!", Colors.orange);
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showSnackBar("Password must be at least 6 characters long!", Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match! Please check again.", Colors.orange);
      return;
    }

    // Attempt Registration via Provider
    String res = provider.registerNewUser(
      username,
      email,
      password,
    );

    if (res == "SUCCESS") {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0F1126),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("🎉 ACCOUNT CREATED!", style: TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold)),
          content: Text("Welcome $username! Your account has been created successfully. Proceed to login.", style: const TextStyle(color: Colors.white70, fontSize: 12)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onNavigateToLogin();
              },
              child: const Text("Proceed to Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } else {
      _showSnackBar(res, Colors.redAccent);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TournamentProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF070914),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.25), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.deepPurpleAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.deepPurpleAccent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Text('CREATE YOUR ACCOUNT', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),

                // 👤 Username Field
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "Username / Full Name",
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white38, size: 18),
                    filled: true,
                    fillColor: Colors.black38,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.deepPurpleAccent)),
                  ),
                ),
                const SizedBox(height: 16),

                // 📧 Email Field
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 18),
                    filled: true,
                    fillColor: Colors.black38,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.deepPurpleAccent)),
                  ),
                ),
                const SizedBox(height: 16),

                // 🔐 Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "Create Password",
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 18),
                      onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                    ),
                    filled: true,
                    fillColor: Colors.black38,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.deepPurpleAccent)),
                  ),
                ),
                const SizedBox(height: 16),

                // 🔐 Confirm Password Field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordObscured,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 18),
                      onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                    ),
                    filled: true,
                    fillColor: Colors.black38,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.deepPurpleAccent)),
                  ),
                ),
                const SizedBox(height: 24),

                // 🚀 Registration Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _handleRegistration(provider),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: widget.onNavigateToLogin,
                    child: const Text("Already have an account? Login here", style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 11)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}