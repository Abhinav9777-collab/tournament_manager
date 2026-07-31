import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tournament_provider.dart';
import '../../services/email_service.dart'; // 🚀 Google Apps Script Email Service Import

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
  final _otpController = TextEditingController();

  bool _isSendingOtp = false;
  bool _isOtpSent = false;
  bool _isEmailVerified = false;

  // 📩 Step 1: Send Live Gmail OTP via Google Apps Script
  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    final name = _usernameController.text.trim();

    if (name.isEmpty) {
      _showSnackBar("Please enter your name/username first!", Colors.orange);
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar("Please enter a valid email address!", Colors.orange);
      return;
    }

    setState(() => _isSendingOtp = true);

    // Call Google Apps Script Service
    bool success = await EmailOtpService.sendOtp(email, name);

    if (mounted) {
      setState(() {
        _isSendingOtp = false;
        if (success) {
          _isOtpSent = true;
        }
      });

      if (success) {
        _showSnackBar("✅ OTP sent successfully to $email! Check Inbox/Spam.", Colors.green);
      } else {
        _showSnackBar("❌ Failed to send OTP. Please check internet/Google Script URL.", Colors.redAccent);
      }
    }
  }

  // 🔑 Step 2: Verify OTP Entered by User
  void _handleVerifyOtp() {
    final inputOtp = _otpController.text.trim();

    if (inputOtp.isEmpty) {
      _showSnackBar("Please enter the 6-digit OTP code!", Colors.orange);
      return;
    }

    if (EmailOtpService.verifyOtp(inputOtp)) {
      setState(() => _isEmailVerified = true);
      _showSnackBar("🎉 Email Verified Successfully!", Colors.green);
    } else {
      _showSnackBar("❌ Incorrect OTP Code. Try again!", Colors.redAccent);
    }
  }

  // 🚀 Step 3: Complete Account Registration
  void _handleRegistration(TournamentProvider provider) {
    if (!_isEmailVerified) {
      _showSnackBar("Please verify your email address via OTP first!", Colors.orange);
      return;
    }

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    String res = provider.registerNewUser(
      username,
      email,
      "secure_pass",
    );

    if (res == "SUCCESS") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0F1126),
          title: const Text("REGISTRATION SUCCESS", style: TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
          content: const Text("Your account has been verified and registered! Proceed to login.", style: TextStyle(color: Colors.white70, fontSize: 12)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onNavigateToLogin();
              },
              child: const Text("Login Now", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
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
                    labelText: "Full Name / Username",
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
                  enabled: !_isEmailVerified,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 18),
                    suffixIcon: _isEmailVerified
                        ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                        : null,
                    filled: true,
                    fillColor: Colors.black38,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.deepPurpleAccent)),
                  ),
                ),
                const SizedBox(height: 16),

                // 📩 Send OTP Button
                if (!_isEmailVerified) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isOtpSent ? Colors.grey[800] : const Color(0xFF6C5CE7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSendingOtp ? null : _handleSendOtp,
                      icon: _isSendingOtp
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.mark_email_read_outlined, size: 18, color: Colors.white),
                      label: Text(
                        _isSendingOtp
                            ? "Sending Email..."
                            : (_isOtpSent ? "Resend OTP" : "Send Gmail OTP"),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 🔑 OTP Input & Verify Section
                if (_isOtpSent && !_isEmailVerified) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _otpController,
                          style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Enter 6-Digit OTP",
                            labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                            filled: true,
                            fillColor: Colors.black38,
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.cyanAccent)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _handleVerifyOtp,
                        child: const Text("Verify", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // 🚀 Final Registration Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEmailVerified ? Colors.green : Colors.deepPurpleAccent.withOpacity(0.4),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isEmailVerified ? () => _handleRegistration(provider) : null,
                  child: Text(
                    _isEmailVerified ? 'Complete Account Registration' : 'Please Verify Email First',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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