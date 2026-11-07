import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/cloud_config.dart';

class StorageService {
  /// Uploads an image and returns its public https URL.
  Future<String> uploadImage(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudConfig.cloudName}/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudConfig.uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('Photo upload failed (${streamed.statusCode})');
    }
    final url = jsonDecode(body)['secure_url'];
    if (url is! String) throw Exception('Photo upload failed');
    return url;
  }
}