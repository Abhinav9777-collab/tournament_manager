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

  void _handleRegistration(TournamentProvider provider) {
    if (_usernameController.text.trim().isEmpty) return;
    
    String res = provider.registerNewUserNode(
      _usernameController.text.trim(),
      "${_usernameController.text.trim()}@nexus.io",
      "secure_pass"
    );

    if (res == "SUCCESS") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0F1126),
          title: const Text("REGISTRATION SUCCESS", style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
          content: const Text("Identity locked into global registries. Proceed to login panel.", style: TextStyle(color: Colors.white70, fontSize: 12)),
          actions: [
            TextButton(onPressed: () { Navigator.pop(context); widget.onNavigateToLogin(); }, child: const Text("Login Node", style: TextStyle(color: Colors.cyanAccent)))
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0F1126),
          title: const Text("CONSTRAINT COLLISION", style: TextStyle(color: Colors.redAccent, fontSize: 13)),
          content: Text(res, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Modify Fields", style: TextStyle(color: Colors.cyanAccent)))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      body: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF070914),
            borderRadius: BorderRadius.circular(30),
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
                    child: const Icon(Icons.assignment_ind_rounded, color: Colors.deepPurpleAccent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Text('PROVISION NODE PROFILE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Create Unique Allocation Username",
                  labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  filled: true,
                  fillColor: Colors.black38,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.deepPurpleAccent)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), minimumSize: const Size(double.infinity, 54)),
                onPressed: () => _handleRegistration(provider),
                child: const Text('Deploy Node Credentials', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: widget.onNavigateToLogin,
                  child: const Text("Already established entity? Decrypt Terminal Panel", style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 11)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}