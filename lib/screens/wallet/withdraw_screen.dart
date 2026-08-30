import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/wallet_service.dart';
import '../../services/api_exception.dart';
import '../../utils/formatters.dart';

/// Confirmed against the real backend: requires bankName,
/// accountName, accountNumber (branch optional), minimum Rs. 1,000.
class WithdrawScreen extends StatefulWidget {
  final double availableBalance;

  const WithdrawScreen({super.key, required this.availableBalance});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _branchController = TextEditingController();

  static const double _minimumWithdrawal = 1000;

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(_amountController.text.trim());

  bool get _canSubmit {
    final amount = _amount;
    return amount != null &&
        amount >= _minimumWithdrawal &&
        amount <= widget.availableBalance &&
        _bankNameController.text.trim().isNotEmpty &&
        _accountNameController.text.trim().isNotEmpty &&
        _accountNumberController.text.trim().isNotEmpty;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await WalletService.instance.requestWithdrawal(
        amount: _amount!,
        bankName: _bankNameController.text.trim(),
        accountName: _accountNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        branch: _branchController.text.trim(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Withdrawal Requested'),
          content: const Text('Your withdrawal request has been submitted and is pending approval.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Unable to submit your withdrawal request. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Withdraw')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Available to withdraw', style: TextStyle(fontSize: 13, color: AppColors.primaryDark)),
                  Text(
                    formatMoney(widget.availableBalance),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Amount', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Minimum Rs. 1,000', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: '0.00', prefixText: 'Rs. '),
            ),
            const SizedBox(height: 20),

            Text('Bank Name', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _bankNameController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'e.g. Commercial Bank'),
            ),
            const SizedBox(height: 20),

            Text('Account Name', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _accountNameController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Name on the account'),
            ),
            const SizedBox(height: 20),

            Text('Account Number', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Account number'),
            ),
            const SizedBox(height: 20),

            Text('Branch (optional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _branchController,
              decoration: const InputDecoration(hintText: 'Branch name'),
            ),

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
                    : const Text('Request Withdrawal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
