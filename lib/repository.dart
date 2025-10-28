import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Repository {
  final Uri backendUrl;

  Repository({required this.backendUrl});
  /// Sends image bytes to a Gradio Space /api/predict endpoint.
  ///
  /// The Gradio predict endpoint expects JSON like:
  /// { "data": ["data:image/png;base64,<BASE64>", "<mode>"], "fn_index": 0 }
  /// and returns a JSON response containing base64 image data in `data`.
  ///
  /// Returns decoded image bytes on success.
  Future<Uint8List> sendImageToGradio({
    required Uint8List imageBytes,
    required String mode,
  }) async {
    final String b64 = base64Encode(imageBytes);
    final String dataUrl = 'data:image/png;base64,$b64';

    final payload = {
      'data': [dataUrl, mode],
      'fn_index': 0,
    };

    final resp = await http.post(
      backendUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Gradio error ${resp.statusCode}: ${resp.reasonPhrase}');
    }

    final Map<String, dynamic> jsonResp = jsonDecode(resp.body);
    final dynamic data = jsonResp['data'];
    if (data == null) throw Exception('Invalid Gradio response: missing data');

    String base64WithPrefix;
    if (data is List && data.isNotEmpty) {
      final first = data[0];
      if (first is String) {
        base64WithPrefix = first;
      } else if (first is List && first.isNotEmpty && first[0] is String) {
        base64WithPrefix = first[0];
      } else {
        throw Exception('Unexpected Gradio response format');
      }
    } else if (data is String) {
      base64WithPrefix = data;
    } else {
      throw Exception('Unexpected Gradio response format');
    }

    final parts = base64WithPrefix.split(',');
    final String b64out = parts.length > 1 ? parts.last : base64WithPrefix;
    return base64Decode(b64out);
  }
}