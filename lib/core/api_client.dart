import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// REST API client. Set the endpoint at build/run time with
/// --dart-define=API_BASE_URL=https://your-api.example.com/api/v1
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  Uri _uri(String path) => Uri.parse('$_baseUrl/${path.replaceFirst(RegExp(r'^/'), '')}');

  Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) =>
      _send('POST', path, body: body);

  Future<Map<String, dynamic>> _send(String method, String path,
      {Map<String, dynamic>? body}) async {
    final headers = await _headers();
    final request = http.Request(method, _uri(path))..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(await _client.send(request));
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(response.statusCode, message?.toString() ?? 'Request failed');
    }
    return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => message;
}
