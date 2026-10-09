import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/customer.dart';
import '../../core/models/transaction.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/audio_feedback_service.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.payments_rounded, color: Color(0xFF16A34A)),
                ),
                const SizedBox(width: 12),
                Text(
                  'Magbayad si ${_currentCustomer.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Natitirang Utang: ${currency.format(_currentCustomer.utangBalance)}',
              style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [50.0, 100.0, 200.0, _currentCustomer.utangBalance].where((v) => v > 0).map((amt) {
                final isFull = amt == _currentCustomer.utangBalance;
                return ActionChip(
                  label: Text(isFull ? 'Buo (${currency.format(amt)})' : currency.format(amt)),
                  onPressed: () {
                    amountController.text = amt.toStringAsFixed(0);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Halaga ng Bayad (₱)',
                hintText: 'Hal. 100',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
                      SnackBar(content: Text(reply), backgroundColor: const Color(0xFF16A34A)),
                    );
                  }
                }
              },
              child: const Text('I-record ang Bayad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFFEE2E2),
                  child: Icon(Icons.add_shopping_cart_rounded, color: Color(0xFFDC2626)),
                ),
                const SizedBox(width: 12),
                Text(
                  'Dagdag Utang: ${_currentCustomer.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Halaga ng Utang (₱)',
                hintText: 'Hal. 150',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Mga Aytem / Note (Opsyonal)',
                hintText: 'Hal. 2 sardinas, bigas',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
                      SnackBar(content: Text(reply), backgroundColor: const Color(0xFFDC2626)),
                    );
                  }
                }
              },
              child: const Text('I-record ang Utang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentCustomer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Balance Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        child: Text(
                          _currentCustomer.name.substring(0, 1),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentCustomer.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      if (_currentCustomer.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _currentCustomer.phone!,
                          style: const TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ],
                      const Divider(height: 30),
                      const Text(
                        'KASALUKUYANG UTANG',
                        style: TextStyle(letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currency.format(_currentCustomer.utangBalance),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Magbayad', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: _showPaymentDialog,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDC2626),
                                side: const BorderSide(color: Color(0xFFDC2626)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Dagdag Utang', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: _showAddUtangDialog,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Kasaysayan ng mga Transaksyon',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (_transactions.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Wala pang nakaraang transaksyon si Suki.', textAlign: TextAlign.center),
                    ),
                  )
                else
                  ..._transactions.map((t) {
                    final isPayment = t.type == 'payment';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPayment ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          child: Icon(
                            isPayment ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                            color: isPayment ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          ),
                        ),
                        title: Text(
                          isPayment ? 'Bayad' : 'Utang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPayment ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          ),
                        ),
                        subtitle: Text(
                          '${t.note ?? t.rawVoiceTranscript ?? 'Walang note'}\n${t.timestamp?.substring(0, 16) ?? ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          '${isPayment ? '-' : '+'}${currency.format(t.totalAmount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isPayment ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
