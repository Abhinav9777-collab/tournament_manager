import 'dart:html' as html;
import 'dart:convert';

void downloadFile(String content, String fileName) {
  try {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'image/svg+xml');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print("Download error: $e");
  }
}