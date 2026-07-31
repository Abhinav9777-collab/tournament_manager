import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class EmailOtpService {
  // 🚀 Google Apps Script Web App URL for Unlimited Free Email OTPs
  static const String googleScriptUrl = 
      'https://script.google.com/macros/s/AKfycbyDq4d8TALsyRYfoBK803t_MDfZ_pTxfK5yaWm-b7uiVqSTDKNaJW4UORUAqOf2ikSh/exec';

  static String activeOtp = '';

  // 🚀 Direct Unlimited Free Email Sending Function (Web & Mobile Compatible)
  static Future<bool> sendOtp(String targetEmail, String userName) async {
    // Generate 6-digit random OTP
    activeOtp = (Random().nextInt(900000) + 100000).toString();

    try {
      // 💡 text/plain allows Netlify / Web Browsers to bypass CORS Preflight Options check
      final response = await http.post(
        Uri.parse(googleScriptUrl),
        headers: {
          'Content-Type': 'text/plain;charset=utf-8',
        },
        body: jsonEncode({
          'email': targetEmail.trim(),
          'otp': activeOtp,
          'name': userName.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> responseData = jsonDecode(response.body);
            if (responseData['status'] == 'SUCCESS') {
              print("✅ Google Apps Script OTP sent successfully to $targetEmail");
              return true;
            }
          } catch (_) {
            // Fallback if script returns raw output on redirect
            return true;
          }
        }
        return true;
      } else {
        print("❌ HTTP Error: Status Code ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Network Error: $e");
      return false;
    }
  }

  // 🔍 Verify OTP Logic
  static bool verifyOtp(String inputOtp) {
    return inputOtp.trim() == activeOtp;
  }
}