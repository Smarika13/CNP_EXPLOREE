import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dtjsx2osj';
  static const String _uploadPreset = 'CNP_activities';

  /// Uploads an image file to Cloudinary and returns the secure URL.
  static Future<String> uploadImage(File imageFile, {String folder = 'activities'}) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['secure_url'] as String;
    } else {
      final json = jsonDecode(body) as Map<String, dynamic>;
      throw Exception(json['error']?['message'] ?? 'Upload failed');
    }
  }
}
