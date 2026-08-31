import 'api_client.dart';
import 'api_exception.dart';

enum AuthFlowType { login, register }

class OtpRequestResult {
  final AuthFlowType flow;
  OtpRequestResult(this.flow);
}

/// Baas-side auth - same backend contract as the customer app's
/// AuthService, but every registration call passes role: 'baas' so
/// the account is correctly flagged server-side for every
/// baas-only endpoint (availability, platform fee, /api/baas/orders,
/// etc). There is no guest flow here - a Baas must always be a real,
/// verified account.
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final _api = ApiClient.instance;

  Future<OtpRequestResult> requestOtp(String mobile) async {
    try {
      await _api.post('/api/auth/login', body: {'mobile': mobile}, auth: false);
      return OtpRequestResult(AuthFlowType.login);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        await _api.post('/api/auth/register/request-otp', body: {'mobile': mobile}, auth: false);
        return OtpRequestResult(AuthFlowType.register);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyLoginOtp(String mobile, String otp) async {
    final data = await _api.post(
      '/api/auth/verify-otp',
      body: {'mobile': mobile, 'otp': otp},
      auth: false,
    );
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    await _api.saveToken(token);
    await _api.saveUser(user);
    return user;
  }

  /// Returns a short-lived (30 min) token - the caller must follow
  /// up with [completeRegistration] to set a name and get a full
  /// session, same pattern as the customer app.
  Future<Map<String, dynamic>> verifyRegisterOtp(String mobile, String otp, {String? referralCode}) async {
    final data = await _api.post(
      '/api/auth/register/verify-otp',
      body: {
        'mobile': mobile,
        'otp': otp,
        'role': 'baas',
        if (referralCode != null && referralCode.isNotEmpty) 'referralCode': referralCode,
      },
      auth: false,
    );
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    await _api.saveToken(token);
    await _api.saveUser(user);
    return user;
  }

  Future<Map<String, dynamic>> completeRegistration({
    required String firstName,
    String? middleName,
    required String lastName,
  }) async {
    final data = await _api.put('/api/users/profile', body: {
      'firstName': firstName,
      if (middleName != null && middleName.isNotEmpty) 'middleName': middleName,
      'lastName': lastName,
    });
    final user = data['user'] as Map<String, dynamic>;
    await _api.saveUser(user);
    return user;
  }

  Future<Map<String, dynamic>?> refreshCurrentUser() async {
    final data = await _api.get('/api/users/me');
    final user = data['user'] as Map<String, dynamic>;
    await _api.saveUser(user);
    return user;
  }

  Future<bool> isLoggedIn() async {
    final token = await _api.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() => _api.clearSession();

  // ---- Security: change email/mobile (both require OTP) ----

  Future<void> requestEmailChangeOtp(String email) =>
      _api.post('/api/security/email/request-otp', body: {'email': email});

  Future<Map<String, dynamic>> verifyEmailChangeOtp(String email, String otp) async {
    final data = await _api.post('/api/security/email/verify-otp', body: {'email': email, 'otp': otp});
    final user = data['user'] as Map<String, dynamic>;
    await _api.saveUser(user);
    return user;
  }

  Future<void> requestMobileChangeOtp(String mobile) =>
      _api.post('/api/security/mobile/request-otp', body: {'mobile': mobile});

  Future<Map<String, dynamic>> verifyMobileChangeOtp(String mobile, String otp) async {
    final data = await _api.post('/api/security/mobile/verify-otp', body: {'mobile': mobile, 'otp': otp});
    final user = data['user'] as Map<String, dynamic>;
    await _api.saveUser(user);
    return user;
  }
}
