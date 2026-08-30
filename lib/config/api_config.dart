/// Single source of truth for the backend URL - same backend the
/// customer app (gobaas-flutter) talks to, since this is the same
/// MYBAAS platform, just the Baas-facing side of it.
class ApiConfig {
  static const String baseUrl = 'https://api.findbass.store';

  // Set to true when running against a local dev backend instead.
  // static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator -> localhost
}
