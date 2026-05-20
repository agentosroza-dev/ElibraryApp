import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiClient {
  static final _baseUrl = ApiConfig.baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _headers({bool authenticate = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authenticate) {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticate = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _headers(authenticate: authenticate);
    final response = await http.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool authenticate = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _headers(authenticate: authenticate);
    final response = await http.get(uri, headers: headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticate = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _headers(authenticate: authenticate);
    final response = await http.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      final preview = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body;
      throw Exception(
        'Unexpected response from server (HTTP ${response.statusCode}). '
        'Expected JSON but got ${contentType.isNotEmpty ? contentType : 'unknown'}. '
        'This may be a server error or network issue. Please try again.',
      );
    }
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to parse server response. Please try again.');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final errors = body['errors'] as Map<String, dynamic>?;
    final message = body['message'] as String?;
    if (errors != null && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        throw Exception(firstError.first.toString());
      }
    }
    throw Exception(message ?? 'Request failed (HTTP ${response.statusCode})');
  }
}
