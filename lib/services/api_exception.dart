/// Thrown by [ApiClient] whenever the backend responds with
/// `success: false` (or a non-2xx status). Mirrors the pattern the
/// web apps use — `error.message` for display, `error.code` for
/// branching on specific cases like MOBILE_REQUIRED or
/// PLATFORM_FEE_DUE (see API_REFERENCE.md, "Common error codes").
class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? data;

  ApiException(this.message, {this.code, this.statusCode, this.data});

  @override
  String toString() => message;
}
