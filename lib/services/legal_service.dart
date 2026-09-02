import 'api_client.dart';

/// Confirmed against the real backend: POST /api/legal/agree records
/// an "I agree" click and, if the account has an email on file,
/// emails a copy of the agreed terms in the given language. Never
/// blocks the action it's attached to (accepting a job) if it
/// fails - the agreement already happened client-side by checking
/// the box.
class LegalService {
  LegalService._internal();
  static final LegalService instance = LegalService._internal();

  final _api = ApiClient.instance;

  Future<void> agree({required String context, required String language}) async {
    try {
      await _api.post('/api/legal/agree', body: {'context': context, 'language': language});
    } catch (_) {
      // Silent - never block the underlying action over this.
    }
  }
}
