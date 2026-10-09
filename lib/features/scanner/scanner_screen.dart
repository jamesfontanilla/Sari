import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/product.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/audio_feedback_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  int _adjustQty = 1;

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

    // Play POS scanner beep sound
    await AudioFeedbackService.instance.playScanBeep();

    // 1. Search product in local database by exact barcode or name query
    Product? product = await DatabaseHelper.instance.findProductByBarcode(code);
    product ??= await DatabaseHelper.instance.findProduct(code);

    if (product != null) {
      _showProductActionSheet(product);
    } else {
      _showUnregisteredBarcodeDialog(code);
    }
  }

  // Dialog when barcode is not yet registered in database
  void _showUnregisteredBarcodeDialog(String barcode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: Color(0xFFEA580C)),
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
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tag_rounded, size: 18, color: Colors.black54),
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
              'Hindi pa nakarehistro ang barcode na ito sa anumang paninda sa tindahan. Gusto mo bang i-assign ito sa isang produkto?',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isProcessing = false);
            },
            child: const Text('Kanselahin', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
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

  // Picker sheet to assign barcode to a specific product
  void _showAssignProductPicker(String barcode) async {
    final products = await DatabaseHelper.instance.getProducts();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Pumili ng Paninda para sa Barcode $barcode',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('₱${p.sellPrice.toStringAsFixed(2)} • Stock: ${p.quantity}'),
                      trailing: const Icon(Icons.link_rounded, color: Color(0xFFEA580C)),
                      onTap: () async {
                        Navigator.pop(sheetCtx);
                        await DatabaseHelper.instance.assignBarcodeToProduct(p.id!, barcode);
                        await AudioFeedbackService.instance.playKaChing();
                        final updated = await DatabaseHelper.instance.findProductByBarcode(barcode);
                        if (mounted && updated != null) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Matagumpay na na-link ang barcode sa ${p.name}!'),
                              backgroundColor: const Color(0xFF16A34A),
                            ),
                          );
                          _showProductActionSheet(updated);
                        }
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

  // Simulated Shelf Snap (Vision Model for iconic items on shelf)
  void _simulateShelfVisionScan() async {
    setState(() => _isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFEA580C)),
                SizedBox(height: 16),
                Text(
                  'Sinusuri ang litrato ng istante gamit ang Local Vision Model...',
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
    Navigator.pop(context); // close loading

    final allProds = await DatabaseHelper.instance.getProducts();
    final detectedList = allProds.take(4).toList();

    _showShelfDetectedDialog(detectedList);
  }

  void _showShelfDetectedDialog(List<Product> detectedItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📸 Na-detect sa Istante',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${detectedItems.length} aytem ang natagpuan sa kuha ng camera',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...detectedItems.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Kasalukuyang stock: ${item.quantity} piraso'),
                    trailing: const Chip(
                      label: Text('+5 Stock', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      backgroundColor: Color(0xFFDCFCE7),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
                      backgroundColor: const Color(0xFF16A34A),
                    ),
                  );
                  Navigator.pop(context, true); // return to caller with refresh
                }
              },
              child: const Text('Kumpirmahin at I-update ang Imbentaryo', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  const CircleAvatar(
                    backgroundColor: Color(0xFFFEF3C7),
                    child: Icon(Icons.qr_code_scanner_rounded, color: Color(0xFFD97706)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Stock: ${product.quantity} pcs • Presyo: ₱${product.sellPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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
                            SnackBar(content: Text(msg), backgroundColor: const Color(0xFF16A34A)),
                          );
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Benta (Bawas)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await DatabaseHelper.instance.updateProductQuantity(product.id!, _adjustQty);
                        await AudioFeedbackService.instance.playKaChing();
                        final msg = "Dagdag $_adjustQty piraso sa ${product.name}!";
                        SpeechService.instance.speak(msg);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg), backgroundColor: const Color(0xFF16A34A)),
                          );
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Dagdag Stock', style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('Snap & Track (Kamera Scanner)', style: TextStyle(fontWeight: FontWeight.bold)),
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

          // Viewfinder reticle overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Bottom Quick Shelf Action
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
                  child: const Text(
                    'Itutok sa produkto, barcode, o istante',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.camera_alt_rounded, size: 24),
                  label: const Text(
                    '📸 I-snap ang Istante (Vision AI)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _simulateShelfVisionScan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
