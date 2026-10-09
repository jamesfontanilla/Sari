import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/product.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/audio_feedback_service.dart';
import '../../core/theme/sari_theme.dart';

class ScannerScreen extends StatefulWidget {
  final String initialMode;
  const ScannerScreen({super.key, this.initialMode = 'shelf'});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  late String _mode; // 'shelf' or 'receipt'
  bool _isProcessing = false;
  int _adjustQty = 1;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);
    await AudioFeedbackService.instance.playScanBeep();

    Product? product = await DatabaseHelper.instance.findProductByBarcode(code);
    product ??= await DatabaseHelper.instance.findProduct(code);

    if (product != null) {
      _showProductActionSheet(product);
    } else {
      _showUnregisteredBarcodeDialog(code);
    }
  }

  void _showUnregisteredBarcodeDialog(String barcode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: SariColors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('Bagong Barcode!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SariColors.cream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SariColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tag_rounded, size: 18, color: SariColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      barcode,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hindi pa nakarehistro ang barcode na ito. Gusto mo bang i-assign ito sa isang produkto?',
              style: TextStyle(fontSize: 14, color: SariColors.ink),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isProcessing = false);
            },
            child: const Text('Kanselahin', style: TextStyle(color: SariColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SariColors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showAssignProductPicker(barcode);
            },
            child: const Text('I-link sa Paninda', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAssignProductPicker(String barcode) async {
    final products = await DatabaseHelper.instance.getProducts();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Text('Pumili ng Paninda para sa Barcode:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final p = products[i];
                    return ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('${p.category} • Presyo: ₱${p.sellPrice.toStringAsFixed(2)}'),
                      trailing: const Icon(Icons.link_rounded, color: SariColors.orange),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(sheetCtx);
                        await DatabaseHelper.instance.assignBarcodeToProduct(p.id!, barcode);
                        await AudioFeedbackService.instance.playKaChing();
                        final msg = "Na-link na ang barcode sa ${p.name}!";
                        SpeechService.instance.speak(msg);
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(msg), backgroundColor: SariColors.green),
                          );
                        }
                        setState(() => _isProcessing = false);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => setState(() => _isProcessing = false));
  }

  void _simulateShelfVisionScan() async {
    setState(() => _isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: SariColors.orange),
                SizedBox(height: 16),
                Text(
                  'Sinusuri ang istante gamit ang Local Vision Model...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.pop(context);

    final allProds = await DatabaseHelper.instance.getProducts();
    final detectedList = allProds.take(4).toList();

    _showShelfDetectedDialog(detectedList);
  }

  void _simulateReceiptScan() async {
    setState(() => _isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: SariColors.orange),
                SizedBox(height: 16),
                Text(
                  'Binabasa ang resibo (ABC Wholesale)...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.pop(context);

    _showReceiptDetectedDialog();
  }

  void _showReceiptDetectedDialog() {
    final receiptItems = [
      {'name': 'Lucky Me Pancit Canton', 'qty': 24, 'cost': 14.0},
      {'name': 'Mega Sardines Red', 'qty': 20, 'cost': 22.0},
      {'name': 'Coca-Cola Mismo 290ml', 'qty': 12, 'cost': 15.0},
    ];
    final totalCost = receiptItems.fold<double>(0.0, (sum, item) => sum + (item['qty'] as int) * (item['cost'] as double));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SariColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  backgroundColor: SariColors.greenSoft,
                  child: Icon(Icons.receipt_long_rounded, color: SariColors.green),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nabasa ko ang resibo',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SariColors.ink),
                      ),
                      Text(
                        'ABC Wholesale Supplier · 3 aytem',
                        style: TextStyle(fontSize: 12, color: SariColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...receiptItems.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SariColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${r['qty']} × ${r['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('₱${((r['qty'] as int) * (r['cost'] as double)).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: SariColors.green)),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kabuuang gastos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('₱${totalCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SariColors.ink)),
              ],
            ),
            const SizedBox(height: 18),
            SariPillButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await AudioFeedbackService.instance.playKaChing();
                final msg = "Na-save ang restock mula sa resibo: ₱${totalCost.toStringAsFixed(0)}!";
                SpeechService.instance.speak(msg);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: SariColors.green),
                  );
                  Navigator.pop(context, true);
                }
              },
              child: const Text('I-save ang restock'),
            ),
          ],
        ),
      ),
    ).then((_) => setState(() => _isProcessing = false));
  }

  void _showShelfDetectedDialog(List<Product> detectedItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SariColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: SariColors.greenSoft,
                  child: Icon(Icons.check_circle_rounded, color: SariColors.green),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📸 Na-detect sa Istante',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SariColors.ink),
                      ),
                      Text(
                        '${detectedItems.length} aytem ang natagpuan sa kuha ng camera',
                        style: const TextStyle(fontSize: 12, color: SariColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...detectedItems.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SariColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Kasalukuyang stock: ${item.quantity} pcs', style: const TextStyle(fontSize: 12, color: SariColors.muted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SariColors.greenSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('+5 Stock', style: TextStyle(fontWeight: FontWeight.bold, color: SariColors.green, fontSize: 12)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SariPillButton(
              onPressed: () async {
                Navigator.pop(ctx);
                for (var item in detectedItems) {
                  await DatabaseHelper.instance.updateProductQuantity(item.id!, 5);
                }
                await AudioFeedbackService.instance.playKaChing();
                final msg = "Na-update na ang stock ng ${detectedItems.length} paninda mula sa litrato ng istante!";
                SpeechService.instance.speak(msg);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: SariColors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Kumpirmahin at I-update'),
            ),
          ],
        ),
      ),
    ).then((_) => setState(() => _isProcessing = false));
  }

  void _showProductActionSheet(Product product) {
    _adjustQty = 1;
    showModalBottomSheet(
      context: context,
      backgroundColor: SariColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SariColors.orangeSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: SariColors.orangeDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SariColors.ink),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Stock: ${product.quantity} pcs • Presyo: ₱${product.sellPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13, color: SariColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_adjustQty > 1) {
                        setSheetState(() => _adjustQty--);
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '$_adjustQty',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SariColors.ink),
                    ),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setSheetState(() => _adjustQty++);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SariPillButton(
                      isSecondary: true,
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await DatabaseHelper.instance.updateProductQuantity(product.id!, -_adjustQty);
                        await DatabaseHelper.instance.recordTransaction(
                          type: 'sale',
                          totalAmount: product.sellPrice * _adjustQty,
                          note: 'Kamera benta: ${product.name} (x$_adjustQty)',
                        );
                        await AudioFeedbackService.instance.playKaChing();
                        final msg = "Benta na-record! ₱${(product.sellPrice * _adjustQty).toStringAsFixed(0)} para sa ${product.name}.";
                        SpeechService.instance.speak(msg);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg), backgroundColor: SariColors.green),
                          );
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Benta (Bawas)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SariPillButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await DatabaseHelper.instance.updateProductQuantity(product.id!, _adjustQty);
                        await AudioFeedbackService.instance.playKaChing();
                        final msg = "Dagdag $_adjustQty piraso sa ${product.name}!";
                        SpeechService.instance.speak(msg);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg), backgroundColor: SariColors.green),
                          );
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Dagdag Stock'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((_) => setState(() => _isProcessing = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Inventory', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                if (state.torchState == TorchState.on) {
                  return const Icon(Icons.flash_on, color: Colors.amber);
                } else {
                  return const Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Viewfinder reticle
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: SariColors.orange, width: 2.5),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // Segmented Toggle at top
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mode = 'shelf'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _mode == 'shelf' ? SariColors.orange : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Center(
                          child: Text(
                            'Shelf',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mode = 'receipt'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _mode == 'receipt' ? SariColors.orange : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Center(
                          child: Text(
                            'Resibo',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _mode == 'shelf' ? 'Itutok sa paninda sa istante o barcode' : 'Itutok sa resibo mula sa supplier',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 12),
                SariPillButton(
                  icon: _mode == 'shelf' ? Icons.camera_alt_rounded : Icons.receipt_long_rounded,
                  onPressed: _mode == 'shelf' ? _simulateShelfVisionScan : _simulateReceiptScan,
                  child: Text(_mode == 'shelf' ? '📸 I-snap ang Istante' : '📄 I-scan ang Resibo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
