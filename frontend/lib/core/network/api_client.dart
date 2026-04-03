import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  late final String baseUrl;

  ApiClient() {
    baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000/api';
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Memproses response agar selalu mereturn Map<String, dynamic> meskipun ada error
  Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      // Agar konsisten, tambahkan status code ke dalam response jika diperlukan nanti
      if (decoded is Map<String, dynamic>) {
        decoded['status_code'] = response.statusCode;
        return decoded;
      }
      return {'success': false, 'message': 'Format response tidak valid', 'status_code': response.statusCode};
    } catch (e) {
      return {'success': false, 'message': 'Gagal memproses response server', 'status_code': response.statusCode};
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    try {
      final response = await http.get(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan: $e'};
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan: $e'};
    }
  }

  /// Mengirim request multipart/form-data (untuk upload file seperti foto selfie).
  /// Menggunakan bytes agar kompatibel dengan Web & Mobile.
  Future<Map<String, dynamic>> multipartPost(
    String endpoint, {
    required Map<String, String> fields,
    List<int>? fileBytes,
    String? fileName,
    String? fileFieldName,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      if (fileBytes != null && fileFieldName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            fileBytes,
            filename: fileName ?? 'photo.jpg',
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan: $e'};
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    try {
      final response = await http.delete(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan: $e'};
    }
  }
}
