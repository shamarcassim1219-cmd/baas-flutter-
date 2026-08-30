import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// TODO: backend eke real base URL eka methanata
const String kBaseUrl = 'https://findbass.store/api';

class PendingFeeException implements Exception {
  final double amount;
  final int settleId;
  PendingFeeException(this.amount, this.settleId);
}

class Api {
  Api._();
  static final Api i = Api._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'baas_token';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    validateStatus: (s) => s != null && s < 500,
  ));

  Future<String?> get token => _storage.read(key: _tokenKey);
  Future<void> saveToken(String t) => _storage.write(key: _tokenKey, value: t);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<Options> _auth() async {
    final t = await token;
    return Options(headers: {
      if (t != null) 'Authorization': 'Bearer $t',
      'Accept': 'application/json',
    });
  }

  Future<Map<String, dynamic>> _unwrap(Response r) async {
    final data = r.data is Map ? Map<String, dynamic>.from(r.data) : <String, dynamic>{};
    if (r.statusCode == 402) {
      throw PendingFeeException(
        (data['amount'] as num?)?.toDouble() ?? 0,
        (data['settle_id'] as num?)?.toInt() ?? 0,
      );
    }
    if (r.statusCode! >= 400) {
      throw Exception(data['message']?.toString() ?? 'Error ${r.statusCode}');
    }
    return data;
  }

  // ---- Auth ----
  Future<void> sendOtp(String phone) async {
    final r = await _dio.post('/baas/auth/send-otp', data: {'phone': phone});
    await _unwrap(r);
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final r = await _dio.post('/baas/auth/verify-otp',
        data: {'phone': phone, 'otp': otp});
    final d = await _unwrap(r);
    final t = d['token']?.toString();
    if (t != null) await saveToken(t);
    return d;
  }

  Future<Map<String, dynamic>> me() async =>
      _unwrap(await _dio.get('/baas/me', options: await _auth()));

  // ---- Online / Settlement ----
  Future<bool> setOnline(bool online) async {
    final r = await _dio.post('/baas/status',
        data: {'is_online': online ? 1 : 0}, options: await _auth());
    final d = await _unwrap(r);
    return (d['is_online'] == 1 || d['is_online'] == true);
  }

  Future<Map<String, dynamic>?> pendingSettlement() async {
    final d = await _unwrap(
        await _dio.get('/baas/settlements/pending', options: await _auth()));
    return d['settlement'] as Map<String, dynamic>?;
  }

  Future<void> paySettlement(int id) async {
    await _unwrap(await _dio.post('/baas/settlements/$id/pay',
        options: await _auth()));
  }

  // ---- Jobs ----
  Future<List<dynamic>> jobs(String status) async {
    final d = await _unwrap(await _dio.get('/baas/jobs',
        queryParameters: {'status': status}, options: await _auth()));
    return (d['jobs'] as List?) ?? [];
  }

  Future<void> jobAction(int jobId, String action) async {
    await _unwrap(await _dio.post('/baas/jobs/$jobId/$action',
        options: await _auth()));
  }

  // ---- Wallet ----
  Future<Map<String, dynamic>> wallet() async =>
      _unwrap(await _dio.get('/baas/wallet', options: await _auth()));
}
