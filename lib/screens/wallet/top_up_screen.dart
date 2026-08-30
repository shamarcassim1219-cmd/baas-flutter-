import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/wallet_service.dart';
import '../../services/api_exception.dart';
import 'payhere_webview_screen.dart';

/// Amount entry for a PayHere payment - used both for a regular
/// wallet top-up and (via [purpose]/[fixedAmount]) for paying the
/// platform fee by card, since the backend's own
/// POST /api/wallet/payhere/create endpoint funds both the same
/// way. Pops back with `true` if the payment completed.
class TopUpScreen extends StatefulWidget {
  final String purpose; // 'topup' | 'platform_fee'
  final double? fixedAmount; // when set (fee payment), amount can't be edited

  const TopUpScreen({super.key, this.purpose = 'topup', this.fixedAmount});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  late final TextEditingController _amountController;
  bool _submitting = false;
  String? _error;

  static const double _minimumTopUp = 100;
  static const List<double> _quickAmounts = [500, 1000, 2500, 5000];

  bool get _isFee => widget.purpose == 'platform_fee';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.fixedAmount != null ? widget.fixedAmount!.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(_amountController.text.trim());

  bool get _canSubmit {
    final amount = _amount;
    if (amount == null) return false;
    if (_isFee) return amount > 0;
    return amount >= _minimumTopUp;
  }

  /// Confirmed against the real backend: POST /api/wallet/payhere/create
  /// returns a flat camelCase object - maps it into the snake_case
  /// shape PayHere's JS SDK actually expects, and fills in items/
  /// return_url/cancel_url, which that response doesn't include.
  Map<String, dynamic> _mapToPayHerePayment(Map<String, dynamic> p) {
    return {
      'sandbox': p['sandbox'] ?? false,
      'merchant_id': p['merchantId'],
      'return_url': null,
      'cancel_url': null,
      'notify_url': p['notify_url'],
      'order_id': p['orderId'],
      'items': _isFee ? 'MYBAAS Platform Fee' : 'MYBAAS Wallet Top-up',
      'amount': p['amount'],
      'currency': p['currency'] ?? 'LKR',
      'hash': p['hash'],
      'first_name': p['firstName'],
      'last_name': p['lastName'],
      'email': p['email'],
      'phone': p['phone'],
      'address': p['address'],
      'city': p['city'],
      'country': p['country'],
    };
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final raw = await WalletService.instance.createPayHerePayment(
        amount: _amount!,
        purpose: widget.purpose,
      );
      final paymentParams = _mapToPayHerePayment(raw);

      if (!mounted) return;

      final completed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => PayHereWebViewScreen(paymentParams: paymentParams)),
      );

      if (!mounted) return;

      if (completed == true) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _submitting = false);
      }
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to start payment. Please try again.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isFee ? 'Pay Platform Fee' : 'Top Up')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(_isFee ? 'Amount Due' : 'Amount (LKR)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              _isFee ? 'Fixed - this covers your current outstanding fee.' : 'Minimum Rs. 100',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              enabled: !_isFee,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: '0.00', prefixText: 'Rs. '),
            ),
            if (!_isFee) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts.map((amount) {
                  return OutlinedButton(
                    onPressed: () {
                      _amountController.text = amount.toStringAsFixed(0);
                      setState(() {});
                    },
                    child: Text('Rs. ${amount.toStringAsFixed(0)}'),
                  );
                }).toList(),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_canSubmit && !_submitting) ? _submit : null,
                child: _submitting
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : const Text('Continue to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
