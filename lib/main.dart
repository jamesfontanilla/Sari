import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'core/database/database_helper.dart';
import 'core/nlp/tagalog_nlp_parser.dart';
import 'core/models/customer.dart';
import 'core/models/product.dart';
import 'core/services/speech_service.dart';
import 'features/scanner/scanner_screen.dart';
import 'features/ledger/customer_detail_screen.dart';
import 'features/settings/settings_screen.dart';
import 'core/services/audio_feedback_service.dart';
import 'core/services/llama_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SariApp());
}

class SariApp extends StatelessWidget {
  const SariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF59E0B), // Warm Amber
          primary: const Color(0xFFEA580C),   // Sari Orange
          secondary: const Color(0xFF16A34A), // Retail Green
          error: const Color(0xFFDC2626),     // Suki Red
          surface: const Color(0xFFF9FAFB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: 'sans-serif',
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final GlobalKey<_DashboardScreenState> _dashKey = GlobalKey();
  final GlobalKey<_UtangLedgerScreenState> _utangKey = GlobalKey();
  final GlobalKey<_InventoryScreenState> _invKey = GlobalKey();

  void _refreshAll() {
    _dashKey.currentState?.loadDashboardData();
    _utangKey.currentState?.loadCustomers();
    _invKey.currentState?.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(key: _dashKey, onRefreshNeeded: _refreshAll),
      UtangLedgerScreen(key: _utangKey, onRefreshNeeded: _refreshAll),
      InventoryScreen(key: _invKey, onRefreshNeeded: _refreshAll),
      const SariInsightsScreen(),
      SettingsScreen(onDataReset: _refreshAll),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_rounded), label: 'Tindahan'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Utang'),
          NavigationDestination(icon: Icon(Icons.inventory_2_rounded), label: 'Paninda'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_rounded), label: 'Sari AI'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Setting'),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// 1. DASHBOARD SCREEN
// ----------------------------------------------------
class DashboardScreen extends StatefulWidget {
  final VoidCallback onRefreshNeeded;
  const DashboardScreen({super.key, required this.onRefreshNeeded});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _todaySales = 0.0;
  double _totalUtang = 0.0;
  List<Product> _lowStockItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final metrics = await DatabaseHelper.instance.getTodayMetrics();
    final lowStock = await DatabaseHelper.instance.getLowStockProducts();
    if (mounted) {
      setState(() {
        _todaySales = metrics['today_sales'] ?? 0.0;
        _totalUtang = metrics['total_utang'] ?? 0.0;
        _lowStockItems = lowStock;
        _isLoading = false;
      });
    }
  }

  void _openCameraScanner() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (ctx) => const ScannerScreen()),
    );
    if (changed == true) {
      widget.onRefreshNeeded();
      loadDashboardData();
    }
  }

  void _showSimulatedVoiceDialog() {
    final textController = TextEditingController();
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
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  child: Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Magsalita o Mag-type kay Sari',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Halimbawa: "Si Mang Juan utang 150 sardinas" o "Benta ko 45"',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (dialogCtx, setDialogState) {
                return Column(
                  children: [
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'Sabihin o i-type ang transaksyon...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            SpeechService.instance.isListening ? Icons.mic : Icons.mic_none,
                            color: SpeechService.instance.isListening ? Colors.red : const Color(0xFFEA580C),
                          ),
                          onPressed: () async {
                            if (SpeechService.instance.isListening) {
                              await SpeechService.instance.stop();
                              setDialogState(() {});
                            } else {
                              await SpeechService.instance.listen(
                                onResult: (words) {
                                  setDialogState(() {
                                    textController.text = words;
                                  });
                                },
                                onListeningChanged: (_) => setDialogState(() {}),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    if (SpeechService.instance.isListening) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '🎙️ Nakikinig si Sari... Magsalita ngayon...',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final query = textController.text.trim();
                if (query.isNotEmpty) {
                  Navigator.pop(ctx);
                  final parsed = TagalogNLPParser.parse(query);

                  if (parsed.type == 'utang' && parsed.customerName != null) {
                    final cust = await DatabaseHelper.instance.findOrCreateCustomer(parsed.customerName!);
                    await DatabaseHelper.instance.recordTransaction(
                      type: 'utang',
                      totalAmount: parsed.amount ?? 0.0,
                      customerId: cust.id,
                      rawTranscript: query,
                    );
                  } else if (parsed.type == 'sale') {
                    await DatabaseHelper.instance.recordTransaction(
                      type: 'sale',
                      totalAmount: parsed.amount ?? 0.0,
                      rawTranscript: query,
                    );
                  } else if (parsed.type == 'payment' && parsed.customerName != null) {
                    final cust = await DatabaseHelper.instance.findOrCreateCustomer(parsed.customerName!);
                    await DatabaseHelper.instance.recordTransaction(
                      type: 'payment',
                      totalAmount: parsed.amount ?? 0.0,
                      customerId: cust.id,
                      rawTranscript: query,
                    );
                  }
                  await AudioFeedbackService.instance.playKaChing();

                  await loadDashboardData();
                  widget.onRefreshNeeded();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(parsed.confirmationResponse),
                        backgroundColor: const Color(0xFF16A34A),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    SpeechService.instance.speak(parsed.confirmationResponse);
                  }
                }
              },
              child: const Text('I-record Transaksyon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        title: const Row(
          children: [
            Text('🏪 Sari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            SizedBox(width: 8),
            Chip(
              label: Text('100% Offline', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 26, color: Color(0xFFEA580C)),
            tooltip: 'Snap & Track (Scanner)',
            onPressed: _openCameraScanner,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadDashboardData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Greeting Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Magandang araw, Tindera! 👋',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Handang tumulong si Sari sa utang at benta mo ngayon.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white70),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              icon: const Icon(Icons.camera_alt_rounded, size: 18),
                              label: const Text('Snap & Track', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: _openCameraScanner,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Benta Ngayong Araw',
                          value: currency.format(_todaySales),
                          icon: Icons.payments_rounded,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Kabuuang Utang',
                          value: currency.format(_totalUtang),
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Low Stock Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kulang sa Tindahan (Restock)',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_lowStockItems.length} aytem',
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_lowStockItems.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Kumpleto ang mga paninda! Walang kulang.'),
                      ),
                    )
                  else
                    ..._lowStockItems.take(5).map((item) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFEE2E2),
                              child: Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('Natitira: ${item.quantity} piraso (Threshold: ${item.reorderThreshold})'),
                            trailing: Text(
                              currency.format(item.sellPrice),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFEA580C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.mic, size: 28),
        label: const Text('Magsalita kay Sari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        onPressed: _showSimulatedVoiceDialog,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// 2. UTANG LEDGER SCREEN
// ----------------------------------------------------
class UtangLedgerScreen extends StatefulWidget {
  final VoidCallback onRefreshNeeded;
  const UtangLedgerScreen({super.key, required this.onRefreshNeeded});

  @override
  State<UtangLedgerScreen> createState() => _UtangLedgerScreenState();
}

class _UtangLedgerScreenState extends State<UtangLedgerScreen> {
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    final custs = await DatabaseHelper.instance.getCustomers();
    if (mounted) setState(() => _customers = custs);
  }

  void _openCustomerDetail(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => CustomerDetailScreen(customer: customer)),
    );
    widget.onRefreshNeeded();
    loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listahan ng Utang (Suki)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _customers.isEmpty
          ? const Center(child: Text('Walang nakalistang may utang.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _customers.length,
              itemBuilder: (ctx, i) {
                final c = _customers[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () => _openCustomerDetail(c),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      child: Text(c.name.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    ),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(c.phone ?? 'Pindutin para makita ang history at magbayad'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currency.format(c.utangBalance),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFFDC2626)),
                        ),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Utang ', style: TextStyle(fontSize: 11, color: Colors.black54)),
                            Icon(Icons.chevron_right, size: 14, color: Colors.black54),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ----------------------------------------------------
// 3. INVENTORY SCREEN
// ----------------------------------------------------
class InventoryScreen extends StatefulWidget {
  final VoidCallback onRefreshNeeded;
  const InventoryScreen({super.key, required this.onRefreshNeeded});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final prods = await DatabaseHelper.instance.getProducts();
    if (mounted) setState(() => _products = prods);
  }

  void _openCameraScanner() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (ctx) => const ScannerScreen()),
    );
    if (changed == true) {
      widget.onRefreshNeeded();
      loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paninda sa Tindahan', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFFEA580C)),
            tooltip: 'Snap & Track',
            onPressed: _openCameraScanner,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (ctx, i) {
          final p = _products[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('${p.category} • Benta: ${currency.format(p.sellPrice)} (Puhunan: ${currency.format(p.buyPrice)})'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.black54),
                    onPressed: () async {
                      await DatabaseHelper.instance.updateProductQuantity(p.id!, -1);
                      widget.onRefreshNeeded();
                      loadProducts();
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.isLowStock ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${p.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: p.isLowStock ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF16A34A)),
                    onPressed: () async {
                      await DatabaseHelper.instance.updateProductQuantity(p.id!, 1);
                      widget.onRefreshNeeded();
                      loadProducts();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------
// 4. SARI AI INSIGHTS SCREEN
// ----------------------------------------------------
class SariInsightsScreen extends StatefulWidget {
  const SariInsightsScreen({super.key});

  @override
  State<SariInsightsScreen> createState() => _SariInsightsScreenState();
}

class _SariInsightsScreenState extends State<SariInsightsScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'sari',
      'text': 'Magandang araw! Ako si Sari, ang iyong AI tindera. Magtanong ka gamit ang boses o text tungkol sa iyong kita, utang, o paubos na paninda!'
    }
  ];

  Future<void> _askQuestion(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    _chatController.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': clean});
    });

    final reply = await LlamaService.instance.askSari(clean);

    setState(() {
      _messages.add({'role': 'sari', 'text': reply});
    });

    // Sari speaks out loud
    SpeechService.instance.speak(reply);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanong kay Sari (AI Tindera)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];
                final isSari = m['role'] == 'sari';
                return Align(
                  alignment: isSari ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isSari ? const Color(0xFFFEF3C7) : const Color(0xFFEA580C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      m['text']!,
                      style: TextStyle(
                        color: isSari ? const Color(0xFF92400E) : Colors.white,
                        fontSize: 15,
                        fontWeight: isSari ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Chips and Input
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        label: const Text('Kumikita ba ako ngayon?'),
                        onPressed: () => _askQuestion('Kumikita ba ako ngayon?'),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Sino may pinakamalaking utang?'),
                        onPressed: () => _askQuestion('Sino may pinakamalaking utang?'),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Anong paubos na paninda?'),
                        onPressed: () => _askQuestion('Anong paubos na paninda?'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        onSubmitted: _askQuestion,
                        decoration: InputDecoration(
                          hintText: 'Magtanong kay Sari...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFEA580C)),
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: () => _askQuestion(_chatController.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
