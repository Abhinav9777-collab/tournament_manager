import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/tournament_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onNavigateToSignup;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onNavigateToSignup,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _currentFormState = 'LOGIN'; // 'LOGIN' or 'SIGNUP'
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  String _statusFeedbackMessage = '';

  // Controllers Matrix
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _evaluatePersistentSessionState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _evaluatePersistentSessionState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TournamentProvider>(context, listen: false);
      if (provider.currentlyLoggedInUser != null) {
        widget.onLoginSuccess();
      }
    });
  }

  // 🚀 Direct Fraud-Proof Registration Call
  void _handleDirectSignup(TournamentProvider provider) {
    final user = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (user.isEmpty || email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      setState(() => _statusFeedbackMessage = "All fields are required.");
      return;
    }

    if (!email.contains('@')) {
      setState(() => _statusFeedbackMessage = "Please enter a valid email address.");
      return;
    }

    if (pass.length < 6) {
      setState(() => _statusFeedbackMessage = "Password must be at least 6 characters long.");
      return;
    }

    if (pass != confirmPass) {
      setState(() => _statusFeedbackMessage = "Passwords do not match.");
      return;
    }

    String registerStatus = provider.registerNewUser(user, email, pass);
    if (registerStatus == "SUCCESS") {
      String deviceTag = "WEB_BROWSER_SESSION";
      String loginStatus = provider.loginUser(user, pass, deviceTag);
      if (loginStatus == "SUCCESS") {
        widget.onLoginSuccess();
      } else {
        setState(() => _statusFeedbackMessage = loginStatus);
      }
    } else {
      setState(() => _statusFeedbackMessage = registerStatus);
    }
  }

  // 🔐 Direct Standard Password Login Call
  void _executeStandardLogin(TournamentProvider provider) {
    final user = _usernameController.text.trim();
    final pass = _passwordController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() => _statusFeedbackMessage = "Username and Password fields cannot be blank.");
      return;
    }

    String deviceTag = "WEB_BROWSER_SESSION";
    String result = provider.loginUser(user, pass, deviceTag);

    if (result == "SUCCESS") {
      widget.onLoginSuccess();
    } else {
      setState(() => _statusFeedbackMessage = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TournamentProvider>(context);

    if (provider.currentlyLoggedInUser != null) {
      _evaluatePersistentSessionState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF03040B),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: CyberPremiumBackgroundPainter())),
          Positioned(
            left: -80,
            top: 140,
            child: Opacity(opacity: 0.04, child: Icon(Icons.shield_outlined, size: 360, color: Colors.purpleAccent.shade400)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBrandBrandingHeader(),
                  const SizedBox(height: 36),
                  Container(
                    width: 440,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090C15).withOpacity(0.96),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _currentFormState == 'LOGIN'
                          ? _buildLoginViewPanel(provider)
                          : _buildSignupViewPanel(provider),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text("© 2026 Tournament Manager. All rights reserved.", style: TextStyle(color: Colors.white.withOpacity(0.18), fontSize: 11, letterSpacing: 0.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginViewPanel(TournamentProvider provider) {
    return Column(
      key: const ValueKey('LoginContentCard'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Column(
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  children: [
                    TextSpan(text: "Welcome ", style: TextStyle(color: Colors.white)),
                    TextSpan(text: "Back!", style: TextStyle(color: Color(0xFF8A56FA))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text("Login to your Tournament Manager account", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12.5)),
              const SizedBox(height: 16),
              Container(width: 36, height: 2, decoration: BoxDecoration(color: const Color(0xFF8A56FA), borderRadius: BorderRadius.circular(1))),
            ],
          ),
        ),
        const SizedBox(height: 36),
        _buildInputSectionLabel("Username"),
        _buildCustomFormInput(_usernameController, Icons.person_rounded, "Enter your username", false, isPasswordField: false),
        const SizedBox(height: 24),
        _buildInputSectionLabel("Password"),
        _buildCustomFormInput(_passwordController, Icons.lock_rounded, "Enter your password", false, isPasswordField: true, isFieldObscured: _isPasswordObscured,
          suffix: IconButton(
            icon: Icon(_isPasswordObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white30, size: 16),
            onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
          ),
        ),
        const SizedBox(height: 14),
        _buildDynamicFeedbackLabel(),
        const SizedBox(height: 14),
        _buildSubmitActionButton("Login →", () => _executeStandardLogin(provider)),
        const SizedBox(height: 28),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              TextButton(
                onPressed: () => setState(() { _currentFormState = 'SIGNUP'; _statusFeedbackMessage = ''; }),
                child: const Text("Create New Account", style: TextStyle(color: Color(0xFF8A56FA), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSignupViewPanel(TournamentProvider provider) {
    return Column(
      key: const ValueKey('SignupContentCard'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Column(
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  children: [
                    TextSpan(text: "Create Your ", style: TextStyle(color: Colors.white)),
                    TextSpan(text: "Account", style: TextStyle(color: Color(0xFF8A56FA))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text("Join Tournament Manager and manage tournaments easily", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(width: 36, height: 2, decoration: BoxDecoration(color: const Color(0xFF8A56FA), borderRadius: BorderRadius.circular(1))),
            ],
          ),
        ),
        const SizedBox(height: 32),

        _buildInputSectionLabel("Full Name / Username Selection"),
        _buildCustomFormInput(_usernameController, Icons.person_rounded, "Choose a unique username", false, isPasswordField: false),
        const SizedBox(height: 18),

        _buildInputSectionLabel("Email Address"),
        _buildCustomFormInput(_emailController, Icons.email_rounded, "Enter your email address", false, isPasswordField: false),
        const SizedBox(height: 18),

        _buildInputSectionLabel("Create Password"),
        _buildCustomFormInput(_passwordController, Icons.lock_rounded, "Create a strong password (min 6 chars)", false, isPasswordField: true, isFieldObscured: _isPasswordObscured,
          suffix: IconButton(
            icon: Icon(_isPasswordObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white38, size: 16),
            onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
          ),
        ),
        const SizedBox(height: 18),

        _buildInputSectionLabel("Confirm Password"),
        _buildCustomFormInput(_confirmPasswordController, Icons.lock_outline_rounded, "Confirm your password", false, isPasswordField: true, isFieldObscured: _isConfirmPasswordObscured,
          suffix: IconButton(
            icon: Icon(_isConfirmPasswordObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white38, size: 16),
            onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
          ),
        ),
        const SizedBox(height: 18),

        _buildDynamicFeedbackLabel(),
        const SizedBox(height: 12),

        _buildSubmitActionButton("Create Account →", () => _handleDirectSignup(provider)),
        const SizedBox(height: 24),

        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              TextButton(
                onPressed: () => setState(() { _currentFormState = 'LOGIN'; _statusFeedbackMessage = ''; }),
                child: const Text("Login here", style: TextStyle(color: Color(0xFF8A56FA), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBrandBrandingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0A21),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF8A56FA).withOpacity(0.3), width: 1.5),
          ),
          child: const Center(child: Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("TOURNAMENT", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            Text("MANAGER", style: TextStyle(color: Color(0xFF8A56FA), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        )
      ],
    );
  }

  Widget _buildInputSectionLabel(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(name, style: TextStyle(color: Colors.white.withOpacity(0.87), fontSize: 12, fontWeight: FontWeight.w400)),
    );
  }

  Widget _buildCustomFormInput(
    TextEditingController controller,
    IconData leadingIcon,
    String hintPlaceholder,
    bool disableField, {
    required bool isPasswordField,
    bool isFieldObscured = false,
    Widget? suffix,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: disableField ? const Color(0xFF141624) : const Color(0xFF05060E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPasswordField ? isFieldObscured : false,
        enabled: !disableField,
        style: TextStyle(color: disableField ? Colors.white30 : Colors.white, fontSize: 13),
        decoration: InputDecoration(
          prefixIcon: Icon(leadingIcon, color: Colors.white30, size: 16),
          suffixIcon: suffix,
          hintText: hintPlaceholder,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.18), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        ),
      ),
    );
  }

  Widget _buildDynamicFeedbackLabel() {
    if (_statusFeedbackMessage.isEmpty) return const SizedBox.shrink();
    bool isSuccess = _statusFeedbackMessage.startsWith("SUCCESS");
    return Text(_statusFeedbackMessage, style: TextStyle(color: isSuccess ? Colors.greenAccent : Colors.redAccent, fontSize: 11));
  }

  Widget _buildSubmitActionButton(String text, VoidCallback? action) {
    final bool isGreyed = action == null;
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: isGreyed
            ? null
            : const LinearGradient(colors: [Color(0xFF5A4AE3), Color(0xFF8A56FA)]),
        color: isGreyed ? Colors.grey.shade900 : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        onPressed: action,
        child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isGreyed ? Colors.white24 : Colors.white)),
      ),
    );
  }
}

class CyberPremiumBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = const Color(0xFF8A56FA).withOpacity(0.08)..strokeWidth = 0.8..style = PaintingStyle.stroke;
    final paintGlowNode = Paint()..color = const Color(0xFF8A56FA).withOpacity(0.4)..style = PaintingStyle.fill;
    final rand = math.Random(42);

    final pathMesh = Path();
    pathMesh.moveTo(0, size.height * 0.85);
    for (double i = 0; i <= size.width; i += 40) {
      double dy = size.height * 0.88 + 35 * math.sin((i / size.width) * 3 * math.pi);
      if (i == 0) {
        pathMesh.moveTo(i, dy);
      } else {
        pathMesh.lineTo(i, dy);
      }
    }
    canvas.drawPath(pathMesh, paintLine);

    final pathMeshCross = Path();
    for (double i = 0; i <= size.width; i += 60) {
      pathMeshCross.moveTo(i, size.height);
      pathMeshCross.quadraticBezierTo(size.width * 0.5, size.height * 0.75, size.width, size.height * 0.9);
    }
    canvas.drawPath(pathMeshCross, paintLine);

    for (int idx = 0; idx < 45; idx++) {
      double px = rand.nextDouble() * size.width;
      double py = size.height * 0.65 + (rand.nextDouble() * size.height * 0.35);
      canvas.drawCircle(Offset(px, py), 1.0 + rand.nextDouble() * 2.2, paintGlowNode);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}