// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

class CertificateService {
  static void downloadWebCertificate(String winnerName, String tournamentName, int score) {
    final String svgContent = '''
    <svg xmlns="http://www.w3.org/2000/svg" width="800" height="600" viewBox="0 0 800 600">
      <rect width="800" height="600" fill="#1e1e2f"/>
      <rect x="20" y="20" width="760" height="560" fill="none" stroke="#gold" stroke-width="5"/>
      <text x="400" y="100" fill="#ffffff" font-size="32" font-family="Arial" text-anchor="middle" font-weight="bold">CERTIFICATE OF VICTORY</text>
      <text x="400" y="180" fill="#aaaaaa" font-size="20" font-family="Arial" text-anchor="middle">This is proudly presented to</text>
      <text x="400" y="260" fill="#ffd700" font-size="40" font-family="Arial" text-anchor="middle" font-weight="bold">$winnerName</text>
      <text x="400" y="330" fill="#ffffff" font-size="22" font-family="Arial" text-anchor="middle">For securing 1st Position in $tournamentName</text>
      <text x="400" y="400" fill="#00ffa3" font-size="24" font-family="Arial" text-anchor="middle">Total Score: $score Points</text>
      <text x="400" y="500" fill="#888888" font-size="16" font-family="Arial" text-anchor="middle">Tournament Manager OS • Verified Winner</text>
    </svg>
    ''';

    final blob = html.Blob([svgContent], 'image/svg+xml');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "${winnerName}_Winner_Certificate.svg")
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}