import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/customer.dart';
import '../../core/models/transaction.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/audio_feedback_service.dart';
import '../../core/theme/sari_theme.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Customer _currentCustomer;
  List<TransactionRecord> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final txns = await DatabaseHelper.instance.getCustomerTransactions(_currentCustomer.id!);
    final allCusts = await DatabaseHelper.instance.getCustomers();
    final updatedCust = allCusts.firstWhere(
      (c) => c.id == _currentCustomer.id,
      orElse: () => _currentCustomer,
    );

    if (mounted) {
      setState(() {
        _transactions = txns;
        _currentCustomer = updatedCust;
        _isLoading = false;
      });
    }
  }

  void _showPaymentDialog() {
    final amountController = TextEditingController();
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: SariColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: SariColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SariColors.greenSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.payments_rounded, color: SariColors.green, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Magbayad si ${_currentCustomer.name}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SariColors.ink),
                      ),
                      Text(
                        'Kasalukuyang Utang: ${currency.format(_currentCustomer.utangBalance)}',
                        style: const TextStyle(color: SariColors.red, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [50.0, 100.0, 200.0, _currentCustomer.utangBalance].where((v) => v > 0).map((amt) {
                final isFull = amt == _currentCustomer.utangBalance;
                return ActionChip(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: SariColors.border),
                  label: Text(
                    isFull ? 'Buo (${currency.format(amt)})' : currency.format(amt),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: SariColors.ink),
                  ),
                  onPressed: () {
                    amountController.text = amt.toStringAsFixed(0);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SariColors.ink),
              decoration: InputDecoration(
                labelText: 'Halaga ng Bayad (₱)',
                hintText: 'Hal. 100',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 18),
            SariPillButton(
              onPressed: () async {
                final val = double.tryParse(amountController.text.trim());
                if (val != null && val > 0) {
                  Navigator.pop(ctx);
                  await DatabaseHelper.instance.recordTransaction(
                    type: 'payment',
                    totalAmount: val,
                    customerId: _currentCustomer.id,
                    note: 'Bayad ni ${_currentCustomer.name}',
                  );
                  await AudioFeedbackService.instance.playKaChing();
                  await _loadHistory();

                  final reply = "Salamat! Nabawas na ang ${currency.format(val)} sa utang ni ${_currentCustomer.name}.";
                  SpeechService.instance.speak(reply);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(reply), backgroundColor: SariColors.green),
                    );
                  }
                }
              },
              child: const Text('I-record ang Bayad'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUtangDialog() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: SariColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: SariColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SariColors.redSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_shopping_cart_rounded, color: SariColors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dagdag Utang: ${_currentCustomer.name}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SariColors.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SariColors.ink),
              decoration: InputDecoration(
                labelText: 'Halaga ng Utang (₱)',
                hintText: 'Hal. 150',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Mga Aytem / Note (Opsyonal)',
                hintText: 'Hal. 2 sardinas, bigas',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 18),
            SariPillButton(
              isDanger: true,
              onPressed: () async {
                final val = double.tryParse(amountController.text.trim());
                if (val != null && val > 0) {
                  Navigator.pop(ctx);
                  await DatabaseHelper.instance.recordTransaction(
                    type: 'utang',
                    totalAmount: val,
                    customerId: _currentCustomer.id,
                    note: noteController.text.trim().isNotEmpty ? noteController.text.trim() : 'Dagdag utang',
                  );
                  await AudioFeedbackService.instance.playKaChing();
                  await _loadHistory();

                  final reply = "Na-lista na ang dagdag ${currency.format(val)} utang ni ${_currentCustomer.name}.";
                  SpeechService.instance.speak(reply);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(reply), backgroundColor: SariColors.red),
                    );
                  }
                }
              },
              child: const Text('I-record ang Utang'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
    final isOwing = _currentCustomer.utangBalance > 0;

    return Scaffold(
      backgroundColor: SariColors.cream,
      appBar: AppBar(
        title: Text(_currentCustomer.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: SariColors.orange))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Customer Hero Section
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: SariTheme.cardDecoration(),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: isOwing ? SariColors.orangeSoft : SariColors.greenSoft,
                        child: Text(
                          _currentCustomer.name.isNotEmpty ? _currentCustomer.name.substring(0, 1).toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: isOwing ? SariColors.orangeDark : SariColors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        currency.format(_currentCustomer.utangBalance),
                        style: SariTheme.money(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: isOwing ? SariColors.red : SariColors.green,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOwing ? SariColors.redSoft : SariColors.greenSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isOwing ? 'May Aktibong Utang' : 'Bayad Na Lahat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOwing ? SariColors.red : SariColors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: SariPillButton(
                              icon: Icons.payments_rounded,
                              onPressed: isOwing ? _showPaymentDialog : null,
                              child: const Text('Magbayad'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SariPillButton(
                              isSecondary: true,
                              icon: Icons.add_circle_outline,
                              onPressed: _showAddUtangDialog,
                              child: const Text('Dagdag Utang'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Transaction History
                const Text(
                  'Kasaysayan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SariColors.ink),
                ),
                const SizedBox(height: 10),

                if (_transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: SariTheme.cardDecoration(),
                    child: const Center(
                      child: Text('Wala pang transaksyon.', style: TextStyle(color: SariColors.muted)),
                    ),
                  )
                  else
                    Container(
                      decoration: SariTheme.cardDecoration(),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _transactions.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final t = _transactions[i];
                          final isPayment = t.type == 'payment';
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isPayment ? SariColors.greenSoft : SariColors.redSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isPayment ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: isPayment ? SariColors.green : SariColors.red,
                              ),
                            ),
                            title: Text(
                              isPayment ? 'Bayad' : 'Utang',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isPayment ? SariColors.green : SariColors.red,
                              ),
                            ),
                            subtitle: Text(
                              '${t.note ?? t.rawVoiceTranscript ?? 'Walang note'}\n${t.timestamp?.substring(0, 16) ?? ''}',
                              style: const TextStyle(fontSize: 11, color: SariColors.muted),
                            ),
                            trailing: Text(
                              '${isPayment ? '-' : '+'}${currency.format(t.totalAmount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isPayment ? SariColors.green : SariColors.red,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
