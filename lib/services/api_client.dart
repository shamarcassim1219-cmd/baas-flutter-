import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// Every screen talks to the backend through this one class. It
/// mirrors the `api()` helper repeated across all three web apps:
/// attach the bearer token if present, parse the JSON body, and
/// throw [ApiException] (message + code) on any non-success response
/// instead of making every call site check `success` by hand.
class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'mybaas_token';
  static const _userKey = 'mybaas_user';

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> saveUser(Map<String, dynamic> user) =>
      _storage.write(key: _userKey, value: jsonEncode(user));

  Future<Map<String, dynamic>?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (query == null || query.isEmpty) return uri;
    // Drop null/empty values so callers can pass optional filters
    // straight through without building the query string by hand.
    final cleaned = <String, String>{};
    query.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        cleaned[key] = value.toString();
      }
    });
    return uri.replace(queryParameters: {...uri.queryParameters, ...cleaned});
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> data;
    try {
      data = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      data = <String, dynamic>{};
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    final success = data['success'] != false;

    if (!ok || !success) {
      throw ApiException(
        (data['message'] as String?) ?? 'Something went wrong.',
        code: data['code'] as String?,
        statusCode: response.statusCode,
        data: data,
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final response = await http.get(_uri(path, query), headers: await _headers(auth: auth));
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final response = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final response = await http.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(String path, {bool auth = true}) async {
    final response = await http.delete(_uri(path), headers: await _headers(auth: auth));
    return _decode(response);
  }
}
