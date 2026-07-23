import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class EmailOtpService {
  static const String serviceId = 'service_mckgkau';
  static const String templateId = 'template_8a5pzan';
  static const String publicKey = 'JSGH77XiaTbGTGVV8';

  static String activeOtp = '';

  // 🚀 Direct Email Sending Function
  static Future<bool> sendOtp(String targetEmail, String userName) async {
    // Generate 6 digit random OTP
    activeOtp = (Random().nextInt(900000) + 100000).toString();

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_email': targetEmail,
            'user_email': targetEmail,
            'to_name': userName,
            'passcode': activeOtp,
            'otp_code': activeOtp,
          }
        }),
      );

      if (response.statusCode == 200) {
        print("✅ EmailJS OTP sent successfully to $targetEmail");
        return true;
      } else {
        print("❌ EmailJS Error: ${response.body}");
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