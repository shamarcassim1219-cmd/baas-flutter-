import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/wallet_service.dart';
import '../../services/api_exception.dart';
import '../../utils/formatters.dart';
import '../../localization/locale_controller.dart';

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

    final t = context.read<LocaleController>().t;

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
          title: Text(t('withdrawalRequested')),
          content: Text(t('withdrawalRequestedDesc')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: Text(t('ok')),
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
    final t = context.watch<LocaleController>().t;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t('withdraw'))),
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
                  Text(t('availableToWithdraw'), style: const TextStyle(fontSize: 13, color: AppColors.primaryDark)),
                  Text(
                    formatMoney(widget.availableBalance),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(t('amount'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(t('minimumWithdrawal'), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: '0.00', prefixText: 'Rs. '),
            ),
            const SizedBox(height: 20),

            Text(t('bankName'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _bankNameController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'e.g. Commercial Bank'),
            ),
            const SizedBox(height: 20),

            Text(t('accountName'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _accountNameController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: t('accountName')),
            ),
            const SizedBox(height: 20),

            Text(t('accountNumber'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: t('accountNumber')),
            ),
            const SizedBox(height: 20),

            Text(t('branchOptional'), style: Theme.of(context).textTheme.titleMedium),
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
                    : Text(t('requestWithdrawal')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
