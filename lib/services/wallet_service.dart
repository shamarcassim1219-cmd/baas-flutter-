import 'api_client.dart';

class WalletBalance {
  final double available;
  final double pending;
  final double withdrawing;
  final double total;

  WalletBalance({
    required this.available,
    required this.pending,
    required this.withdrawing,
    required this.total,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      available: (json['available'] as num?)?.toDouble() ?? 0,
      pending: (json['pending'] as num?)?.toDouble() ?? 0,
      withdrawing: (json['withdrawing'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class LedgerEntry {
  final String type;
  final double amount;
  final String state;
  final String note;
  final DateTime createdAt;

  LedgerEntry({
    required this.type,
    required this.amount,
    required this.state,
    required this.note,
    required this.createdAt,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      type: json['type'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      state: json['state'] as String? ?? 'available',
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Confirmed against the real backend: GET /api/wallet ->
/// {wallet: {available, pending, withdrawing, total}, ledger: [...]}
/// - same endpoint as the customer app's wallet, since earnings
/// from accepted orders and platform-fee deductions land in the
/// same ledger. No top-up here (unlike the customer app) - a Baas's
/// wallet is only ever funded by order earnings.
class WalletService {
  WalletService._internal();
  static final WalletService instance = WalletService._internal();

  final _api = ApiClient.instance;

  Future<(WalletBalance, List<LedgerEntry>)> load() async {
    final data = await _api.get('/api/wallet');
    final balance = WalletBalance.fromJson(data['wallet'] as Map<String, dynamic>? ?? {});
    final ledgerRaw = (data['ledger'] as List?) ?? [];
    final ledger = ledgerRaw.map((e) => LedgerEntry.fromJson(e as Map<String, dynamic>)).toList();
    return (balance, ledger);
  }

  /// Confirmed against the real backend: POST /api/wallet/withdrawals
  /// requires bankName, accountName, accountNumber (branch is
  /// optional). Minimum withdrawal is Rs. 1,000.
  Future<void> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountName,
    required String accountNumber,
    String? branch,
  }) async {
    await _api.post('/api/wallet/withdrawals', body: {
      'amount': amount,
      'bankName': bankName,
      'accountName': accountName,
      'accountNumber': accountNumber,
      if (branch != null && branch.isNotEmpty) 'branch': branch,
    });
  }

  /// Confirmed against the real backend: POST /api/wallet/payhere/create
  /// returns a flat camelCase object (merchantId, orderId,
  /// firstName...) - camelCase, not the snake_case PayHere's JS SDK
  /// expects. [purpose] lets this same endpoint fund either a
  /// regular top-up or a platform-fee payment - the backend's own
  /// notify webhook routes the money accordingly, never touching
  /// wallet balance for a fee payment.
  Future<Map<String, dynamic>> createPayHerePayment({
    required double amount,
    String purpose = 'topup',
  }) async {
    final data = await _api.post('/api/wallet/payhere/create', body: {
      'amount': amount,
      'purpose': purpose,
    });
    return data;
  }
}
