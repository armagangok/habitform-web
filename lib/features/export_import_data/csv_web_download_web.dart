import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Triggers a file download in the browser (no server round-trip).
void downloadCsvInBrowser(String filename, String csvContent) {
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob(<Object>[bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
