import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/product.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/audio_feedback_service.dart';
import '../../core/theme/sari_theme.dart';

class PamamalengkeItem {
  final Product product;
  int quantityToBuy;
  bool isChecked;

  PamamalengkeItem({
    required this.product,
    required this.quantityToBuy,
    this.isChecked = false,
  });

  double get subtotalCost => quantityToBuy * product.buyPrice;
}

class PamamalengkeScreen extends StatefulWidget {
  final VoidCallback onRestockSaved;

  const PamamalengkeScreen({
    super.key,
    required this.onRestockSaved,
  });

  @override
  State<PamamalengkeScreen> createState() => _PamamalengkeScreenState();
}

class _PamamalengkeScreenState extends State<PamamalengkeScreen> {
  List<PamamalengkeItem> _items = [];
  bool _isLoading = true;
  final TextEditingController _budgetController = TextEditingController();
  double? _userBudget;

  @override
  void initState() {
    super.initState();
    _loadRestockItems();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadRestockItems() async {
    final allProducts = await DatabaseHelper.instance.getProducts();
    // Prioritize low stock items
    final lowStock = allProducts.where((p) => p.isLowStock).toList();
    final itemsToPlan = lowStock.isNotEmpty ? lowStock : allProducts.take(8).toList();

    final planned = itemsToPlan.map((p) {
      // Calculate suggested restock quantity
      final needed = (p.reorderThreshold * 2) - p.quantity;
      final qty = needed > 0 ? needed : 5;
      return PamamalengkeItem(
        product: p,
        quantityToBuy: qty,
        isChecked: false,
      );
    }).toList();

    if (mounted) {
      setState(() {
        _items = planned;
        _isLoading = false;
      });
    }
  }

  double get _totalEstimatedCost {
    return _items.fold(0.0, (sum, item) => sum + item.subtotalCost);
  }

  int get _totalPiecesToBuy {
    return _items.fold(0, (sum, item) => sum + item.quantityToBuy);
  }

  void _showAddProductPicker() async {
    final allProducts = await DatabaseHelper.instance.getProducts();
    final currentIds = _items.map((i) => i.product.id).toSet();
    final available = allProducts.where((p) => !currentIds.contains(p.id)).toList();

    if (!mounted) return;

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nasa listahan na ang lahat ng produkto!')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: SariColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
            const SizedBox(height: 14),
            Text(
              'Pumili ng Idaragdag sa Pamamalengke',
              style: SariTheme.heading(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: available.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = available[i];
                  return Container(
                    decoration: SariTheme.cardDecoration(),
                    child: ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('Stock: ${p.quantity} • Puhunan: ₱${p.buyPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: SariColors.muted)),
                      trailing: const Icon(Icons.add_circle_outline, color: SariColors.orange),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _items.add(PamamalengkeItem(product: p, quantityToBuy: 5));
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyShareableList() {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
    final buffer = StringBuffer();
    buffer.writeln('🛒 Listahan sa Pamamalengke — Sari-Sari Store');
    buffer.writeln('Petsa: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}');
    buffer.writeln('----------------------------------------');
    for (var item in _items) {
      buffer.writeln('• ${item.product.name}');
      buffer.writeln('   Bilang: +${item.quantityToBuy} piraso (Puhunan: ${currency.format(item.subtotalCost)})');
    }
    buffer.writeln('----------------------------------------');
    buffer.writeln('Kabuuang Puhunan: ${currency.format(_totalEstimatedCost)}');
    if (_userBudget != null) {
      buffer.writeln('Dala kong Budget: ${currency.format(_userBudget!)}');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Na-kopya na ang listahan! Puwede nang i-paste sa SMS o Messenger.'),
        backgroundColor: SariColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _speakSummary() {
    final msg = "May ${_items.length} aytem sa listahan mo ng pamamalengke. Kailangan mo ng humigit-kumulang ₱${_totalEstimatedCost.toStringAsFixed(0)} para sa puhunan.";
    SpeechService.instance.speak(msg);
  }

  Future<void> _completeRestock() async {
    if (_items.isEmpty) return;

    for (var item in _items) {
      if (item.quantityToBuy > 0) {
        await DatabaseHelper.instance.updateProductQuantity(item.product.id!, item.quantityToBuy);
      }
    }

    await AudioFeedbackService.instance.playKaChing();
    final msg = "Galing! Na-update na ang stock ng ${_items.length} produkto mula sa pamamalengke.";
    SpeechService.instance.speak(msg);

    widget.onRestockSaved();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: SariColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Scaffold(
      backgroundColor: SariColors.cream,
      appBar: AppBar(
        title: Text('Listahan ng Pamamalengke', style: SariTheme.heading(fontSize: 18, fontWeight: FontWeight.w800)),
        backgroundColor: SariColors.cream,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: SariColors.ink),
            tooltip: 'Kopyahin ang listahan',
            onPressed: _copyShareableList,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_outlined, color: SariColors.orange),
            tooltip: 'Sabihin ni Sari',
            onPressed: _speakSummary,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: SariColors.orange))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Mascot Advice Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: SariTheme.cardDecoration(),
                  child: Row(
                    children: [
                      const SariMascot(pose: SariPose.insights, size: 68),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gabay sa Palengke ni Sari',
                              style: SariTheme.heading(fontSize: 14, fontWeight: FontWeight.w800, color: SariColors.orangeDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pinili ko ang mga paubos na paninda para hindi ka maubusan ng paninda sa mga suki!',
                              style: SariTheme.body(fontSize: 12, color: SariColors.muted, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Budget & Cost Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF2E6), Color(0xFFFFE8D6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SariColors.orangeSoft, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kailangang Puhunan', style: SariTheme.body(fontSize: 12, fontWeight: FontWeight.w600, color: SariColors.muted)),
                              const SizedBox(height: 2),
                              Text(
                                currency.format(_totalEstimatedCost),
                                style: SariTheme.money(fontSize: 26, fontWeight: FontWeight.w800, color: SariColors.orangeDark),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: const [BoxShadow(color: Color(0x0C78481E), blurRadius: 6)],
                            ),
                            child: Text(
                              '$_totalPiecesToBuy pcs kabuuan',
                              style: SariTheme.heading(fontSize: 12, fontWeight: FontWeight.w700, color: SariColors.ink),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: SariColors.border),
                      const SizedBox(height: 8),

                      // Dala kong Pera (Budget Input)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _budgetController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Magkano ang dala mong pera? (₱)',
                                labelStyle: const TextStyle(fontSize: 12, color: SariColors.muted),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SariColors.border)),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _userBudget = double.tryParse(val.trim());
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_userBudget != null) ...[
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final diff = _userBudget! - _totalEstimatedCost;
                            final isEnough = diff >= 0;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isEnough ? SariColors.greenSoft : SariColors.redSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isEnough ? Icons.check_circle_rounded : Icons.warning_rounded,
                                    size: 16,
                                    color: isEnough ? SariColors.green : SariColors.red,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      isEnough
                                          ? 'Kasya ang budget! May matitira pang ${currency.format(diff)}.'
                                          : 'Kulang ng ${currency.format(diff.abs())} sa tinatayang listahan.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isEnough ? SariColors.green : SariColors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mga Aytem na Bibilhin (${_items.length})',
                      style: SariTheme.heading(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16, color: SariColors.orange),
                      label: Text('Magdagdag', style: SariTheme.heading(fontSize: 13, fontWeight: FontWeight.w700, color: SariColors.orange)),
                      onPressed: _showAddProductPicker,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Checklist
                ...List.generate(_items.length, (index) {
                  final item = _items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: SariTheme.cardDecoration(),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Checkbox(
                        value: item.isChecked,
                        activeColor: SariColors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          setState(() {
                            item.isChecked = val ?? false;
                          });
                        },
                      ),
                      title: Text(
                        item.product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: SariColors.ink,
                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Puhunan: ${currency.format(item.product.buyPrice)}/pc • Kasalukuyan: ${item.product.quantity} pcs',
                        style: const TextStyle(fontSize: 11, color: SariColors.muted),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.remove, size: 14),
                            onPressed: () {
                              if (item.quantityToBuy > 1) {
                                setState(() => item.quantityToBuy--);
                              }
                            },
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 28),
                            child: Text(
                              '+${item.quantityToBuy}',
                              textAlign: TextAlign.center,
                              style: SariTheme.heading(fontSize: 14, fontWeight: FontWeight.w800, color: SariColors.orangeDark),
                            ),
                          ),
                          IconButton.filledTonal(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.add, size: 14),
                            onPressed: () {
                              setState(() => item.quantityToBuy++);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: SariColors.border)),
          boxShadow: [BoxShadow(color: Color(0x0C78481E), blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SariPillButton(
                  icon: Icons.check_circle_rounded,
                  onPressed: _items.isEmpty ? null : _completeRestock,
                  child: const Text('Nabili Ko Na Lahat! (I-restock)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
