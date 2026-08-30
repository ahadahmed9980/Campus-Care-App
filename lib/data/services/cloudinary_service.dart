import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = "dutsquswv";
  static const String _uploadPreset = "heaz0p48";

  static Future<String?> uploadImage({
    required Uint8List bytes,
    String? fileName,
    String folderName = "requests",
  }) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri);

      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folderName;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename:
              fileName ?? "upload_${DateTime.now().millisecondsSinceEpoch}.jpg",
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? secureUrl = data['secure_url'];

        if (secureUrl == null || secureUrl.isEmpty) {
          return null;
        }
        return secureUrl;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
