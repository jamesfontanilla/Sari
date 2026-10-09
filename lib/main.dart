import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'core/database/database_helper.dart';
import 'core/nlp/tagalog_nlp_parser.dart';
import 'core/models/customer.dart';
import 'core/models/product.dart';
import 'core/services/speech_service.dart';
import 'core/services/audio_feedback_service.dart';
import 'core/services/llama_service.dart';
import 'core/theme/sari_theme.dart';
import 'features/scanner/scanner_screen.dart';
import 'features/ledger/customer_detail_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/onboarding/welcome_screen.dart';

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
      theme: SariTheme.lightTheme,
      home: FutureBuilder<bool>(
        future: DatabaseHelper.instance.isOnboarded(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: SariColors.cream,
              body: Center(
                child: CircularProgressIndicator(color: SariColors.orange),
              ),
            );
          }
          final isOnboarded = snapshot.data ?? false;
          if (isOnboarded) {
            return const MainNavigationShell();
          } else {
            return const WelcomeScreen();
          }
        },
      ),
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

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        key: _dashKey,
        onRefreshNeeded: _refreshAll,
        onNavigateToTab: _navigateToTab,
      ),
      UtangLedgerScreen(key: _utangKey, onRefreshNeeded: _refreshAll),
      InventoryScreen(key: _invKey, onRefreshNeeded: _refreshAll),
      const SariAiChatScreen(),
      SettingsScreen(onDataReset: _refreshAll),
    ];

    return Scaffold(
      backgroundColor: SariColors.cream,
      body: SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: SariColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: SariColors.orangeSoft,
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined, color: SariColors.muted),
              selectedIcon: Icon(Icons.storefront_rounded, color: SariColors.orange),
              label: 'Tindahan',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined, color: SariColors.muted),
              selectedIcon: Icon(Icons.menu_book_rounded, color: SariColors.orange),
              label: 'Utang',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined, color: SariColors.muted),
              selectedIcon: Icon(Icons.inventory_2_rounded, color: SariColors.orange),
              label: 'Paninda',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded, color: SariColors.muted),
              selectedIcon: Icon(Icons.chat_bubble_rounded, color: SariColors.orange),
              label: 'Sari AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: SariColors.muted),
              selectedIcon: Icon(Icons.settings_rounded, color: SariColors.orange),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 1. DASHBOARD SCREEN (Tindahan)
// ----------------------------------------------------
class DashboardScreen extends StatefulWidget {
  final VoidCallback onRefreshNeeded;
  final void Function(int tabIndex) onNavigateToTab;

  const DashboardScreen({
    super.key,
    required this.onRefreshNeeded,
    required this.onNavigateToTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _todaySales = 0.0;
  double _totalUtang = 0.0;
  List<Product> _lowStockItems = [];
  int _debtorCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final metrics = await DatabaseHelper.instance.getTodayMetrics();
    final lowStock = await DatabaseHelper.instance.getLowStockProducts();
    final customers = await DatabaseHelper.instance.getCustomers();
    final owing = customers.where((c) => c.utangBalance > 0).length;

    if (mounted) {
      setState(() {
        _todaySales = metrics['today_sales'] ?? 0.0;
        _totalUtang = metrics['total_utang'] ?? 0.0;
        _lowStockItems = lowStock;
        _debtorCount = owing;
        _isLoading = false;
      });
    }
  }

  void _openCameraScanner({String? mode}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (ctx) => ScannerScreen(initialMode: mode ?? 'shelf')),
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
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final isListening = SpeechService.instance.isListening;
          return Container(
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
                    SariMascot(
                      pose: isListening ? SariPose.listening : SariPose.idle,
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isListening ? 'Nakikinig si Sari...' : 'Magsalita kay Sari',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: SariColors.ink,
                            ),
                          ),
                          const Text(
                            '100% Offline Voice Assistant',
                            style: TextStyle(color: SariColors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Subukan sabihin o i-tap:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: SariColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSampleChip("Si Mang Juan utang 150 sardinas", textController, setDialogState),
                    _buildSampleChip("Benta ko 45", textController, setDialogState),
                    _buildSampleChip("Bayad ni Aling Rosa 100", textController, setDialogState),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  style: const TextStyle(color: SariColors.ink, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Sabihin o i-type ang transaksyon...',
                    hintStyle: const TextStyle(color: SariColors.muted),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: SariColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: SariColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: SariColors.orange, width: 1.5),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: isListening ? SariColors.red : SariColors.orange,
                        size: 26,
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
                if (isListening) ...[
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.graphic_eq_rounded, color: SariColors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Nakikinig si Sari... Magsalita ngayon...',
                        style: TextStyle(color: SariColors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                SariPillButton(
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
                            backgroundColor: SariColors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        SpeechService.instance.speak(parsed.confirmationResponse);
                      }
                    }
                  },
                  child: const Text('I-record Transaksyon'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSampleChip(String text, TextEditingController controller, StateSetter setDialogState) {
    return GestureDetector(
      onTap: () {
        setDialogState(() {
          controller.text = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: SariColors.border),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: SariColors.ink, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: SariColors.cream,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: SariColors.orange))
          : RefreshIndicator(
              color: SariColors.orange,
              onRefresh: loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Top Header with Streak and Settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: SariColors.border),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0C78481E), blurRadius: 10, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Text('🔥', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text(
                              '3 araw na sunod-sunod',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: SariColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: SariColors.border),
                          shape: const CircleBorder(),
                        ),
                        icon: const Icon(Icons.settings_outlined, color: SariColors.ink, size: 20),
                        onPressed: () {
                          widget.onNavigateToTab(4); // Go to Settings
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Date Eyebrow
                  Text(
                    tagalogDateEyebrow(now),
                    style: SariTheme.heading(
                      color: SariColors.muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Hero Greeting
                  RichText(
                    text: TextSpan(
                      text: '${tagalogGreeting(now)}, ',
                      style: SariTheme.heading(
                        color: SariColors.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: 'Aling Maria!',
                          style: SariTheme.heading(
                            color: SariColors.ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Hero Sari Mascot Card with Speech Bubble
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: SariTheme.cardDecoration(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SariMascot(pose: SariPose.idle, size: 92),
                        const SizedBox(width: 14),
                        Expanded(
                          child: InkWell(
                            onTap: () => widget.onNavigateToTab(3), // Go to Chat
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: SariColors.cream,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: SariColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Text(
                                        'Sari',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: SariColors.orange,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: SariColors.muted),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _todaySales > 0
                                        ? 'May ${currency.format(_todaySales)} kang benta ngayong araw. Sapat pa ang karamihan ng paninda mo!'
                                        : 'Handa na ako! Sabihin o i-scan ang unang benta mo ngayong araw.',
                                    style: const TextStyle(
                                      color: SariColors.ink,
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section: Mabilis na Gawain (5 Action Tiles)
                  Text(
                    'Mabilis na Gawain',
                    style: SariTheme.heading(fontSize: 15, fontWeight: FontWeight.w800, color: SariColors.ink),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickTile(
                        icon: Icons.mic_rounded,
                        label: 'Sabihin',
                        onTap: _showSimulatedVoiceDialog,
                      ),
                      _buildQuickTile(
                        icon: Icons.camera_alt_rounded,
                        label: 'Kunan',
                        onTap: () => _openCameraScanner(mode: 'shelf'),
                      ),
                      _buildQuickTile(
                        icon: Icons.receipt_long_rounded,
                        label: 'Resibo',
                        onTap: () => _openCameraScanner(mode: 'receipt'),
                      ),
                      _buildQuickTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Tanungin',
                        onTap: () => widget.onNavigateToTab(3),
                      ),
                      _buildQuickTile(
                        icon: Icons.menu_book_rounded,
                        label: 'Utang',
                        onTap: () => widget.onNavigateToTab(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary Grid (Benta Ngayon & Utang Total)
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Benta Ngayon',
                          amount: currency.format(_todaySales),
                          note: '+8% vs. kahapon',
                          tone: 'good',
                          onTap: () => widget.onNavigateToTab(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Utang Total',
                          amount: currency.format(_totalUtang),
                          note: '$_debtorCount suki',
                          tone: 'bad',
                          onTap: () => widget.onNavigateToTab(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Paglago ng Benta Mini Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: SariTheme.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Paglago ng benta',
                              style: SariTheme.heading(fontWeight: FontWeight.w800, fontSize: 15, color: SariColors.ink),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: SariColors.greenSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                '+14% vs. nakaraang linggo',
                                style: TextStyle(
                                  color: SariColors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Mini weekly bar representation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildMiniBar('Lun', 0.4),
                            _buildMiniBar('Mar', 0.6),
                            _buildMiniBar('Miy', 0.5),
                            _buildMiniBar('Huw', 0.8),
                            _buildMiniBar('Biy', 0.9),
                            _buildMiniBar('Sab', 0.75),
                            _buildMiniBar('Lin', 0.65),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 4),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tingnan ang puhunan at kita',
                              style: TextStyle(color: SariColors.muted, fontSize: 13),
                            ),
                            Icon(Icons.chevron_right, size: 18, color: SariColors.muted),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Low Stock Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: SariColors.orange, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Low Stock',
                            style: SariTheme.heading(fontSize: 15, fontWeight: FontWeight.w800, color: SariColors.ink),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigateToTab(2),
                        child: const Row(
                          children: [
                            Text(
                              'Tingnan lahat',
                              style: TextStyle(color: SariColors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Icon(Icons.chevron_right, size: 16, color: SariColors.orange),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_lowStockItems.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: SariTheme.cardDecoration(),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: SariColors.green, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sapat ang lahat ng paninda mo!',
                              style: TextStyle(color: SariColors.ink, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: SariTheme.cardDecoration(),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _lowStockItems.take(3).length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final item = _lowStockItems[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: SariColors.orangeSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: SariColors.orangeDark),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SariColors.ink),
                            ),
                            subtitle: Text(
                              '${item.quantity} piraso na lang (dapat ${item.reorderThreshold})',
                              style: const TextStyle(color: SariColors.muted, fontSize: 12),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: SariColors.redSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Low',
                                style: TextStyle(
                                  color: SariColors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SariColors.orange,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.mic, size: 26),
        label: const Text('Sabihin kay Sari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        onPressed: _showSimulatedVoiceDialog,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildQuickTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: SariColors.border),
              boxShadow: const [
                BoxShadow(color: Color(0x0C78481E), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
            child: Icon(icon, color: SariColors.orange, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: SariColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String amount,
    required String note,
    required String tone,
    required VoidCallback onTap,
  }) {
    final isGood = tone == 'good';
    final accentColor = isGood ? SariColors.green : SariColors.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: SariTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: SariTheme.heading(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isGood ? SariColors.green : SariColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              amount,
              style: SariTheme.money(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              note,
              style: SariTheme.heading(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBar(String day, double heightFraction) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 60 * heightFraction,
          decoration: BoxDecoration(
            color: SariColors.orange.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 11, color: SariColors.muted)),
      ],
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
  List<Customer> _allCustomers = [];
  String _filter = 'all'; // 'all', 'owing', 'paid'
  bool _isAddingCustomer = false;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  String? _addError;

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    final custs = await DatabaseHelper.instance.getCustomers();
    if (mounted) setState(() => _allCustomers = custs);
  }

  void _openCustomerDetail(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => CustomerDetailScreen(customer: customer)),
    );
    widget.onRefreshNeeded();
    loadCustomers();
  }

  Future<void> _saveNewCustomer() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    if (_allCustomers.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      setState(() => _addError = 'Nandiyan na si $name sa listahan.');
      return;
    }

    final initialDebt = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final cust = await DatabaseHelper.instance.findOrCreateCustomer(name);

    if (initialDebt > 0) {
      await DatabaseHelper.instance.recordTransaction(
        type: 'utang',
        totalAmount: initialDebt,
        customerId: cust.id,
        note: 'Unang utang na inilista',
      );
    }

    _nameCtrl.clear();
    _amountCtrl.clear();
    setState(() {
      _isAddingCustomer = false;
      _addError = null;
    });

    widget.onRefreshNeeded();
    await loadCustomers();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Naidagdag si $name!'),
          backgroundColor: SariColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
    final owing = _allCustomers.where((c) => c.utangBalance > 0).toList();
    final paid = _allCustomers.where((c) => c.utangBalance == 0).toList();
    final totalDebt = _allCustomers.fold<double>(0.0, (sum, c) => sum + c.utangBalance);

    List<Customer> displayed = _allCustomers;
    if (_filter == 'owing') displayed = owing;
    if (_filter == 'paid') displayed = paid;

    return Scaffold(
      backgroundColor: SariColors.cream,
      appBar: AppBar(
        title: const Text('Utang ng mga Suki'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Header Sum & Add Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kabuuang utang ${currency.format(totalDebt)} · ${owing.length} suki',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SariColors.ink),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isAddingCustomer = !_isAddingCustomer;
                    _addError = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isAddingCustomer ? SariColors.muted : SariColors.orange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _isAddingCustomer ? 'Isara' : '+ Magdagdag',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Inline Add Form
          if (_isAddingCustomer) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: SariTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Magdagdag ng umutang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Pangalan',
                      hintText: 'Hal. Mang Pepe',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Utang ngayon (₱)',
                      hintText: '0',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (_addError != null) ...[
                    const SizedBox(height: 8),
                    Text(_addError!, style: const TextStyle(color: SariColors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SariPillButton(
                          onPressed: _saveNewCustomer,
                          child: const Text('I-save'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SariPillButton(
                          isGhost: true,
                          onPressed: () => setState(() => _isAddingCustomer = false),
                          child: const Text('Kanselahin'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Filter Chips
          Row(
            children: [
              SariFilterChip(
                label: 'Lahat (${_allCustomers.length})',
                isSelected: _filter == 'all',
                onTap: () => setState(() => _filter = 'all'),
              ),
              const SizedBox(width: 8),
              SariFilterChip(
                label: 'May Utang (${owing.length})',
                isSelected: _filter == 'owing',
                onTap: () => setState(() => _filter = 'owing'),
              ),
              const SizedBox(width: 8),
              SariFilterChip(
                label: 'Bayad na (${paid.length})',
                isSelected: _filter == 'paid',
                onTap: () => setState(() => _filter = 'paid'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Customers List
          if (displayed.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: SariTheme.cardDecoration(),
              child: const Column(
                children: [
                  SariMascot(pose: SariPose.empty, size: 90),
                  SizedBox(height: 14),
                  Text(
                    'Wala pang nakalistang suki dito.',
                    style: TextStyle(color: SariColors.muted, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: SariTheme.cardDecoration(),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayed.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final c = displayed[i];
                  final isOwing = c.utangBalance > 0;
                  return ListTile(
                    onTap: () => _openCustomerDetail(c),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isOwing ? SariColors.orangeSoft : SariColors.greenSoft,
                      child: Text(
                        c.name.isNotEmpty ? c.name.substring(0, 1).toUpperCase() : '?',
                        style: TextStyle(
                          color: isOwing ? SariColors.orangeDark : SariColors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      c.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: SariColors.ink),
                    ),
                    subtitle: Text(
                      isOwing ? 'May aktibong utang' : 'Bayad na lahat',
                      style: const TextStyle(color: SariColors.muted, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currency.format(c.utangBalance),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isOwing ? SariColors.red : SariColors.green,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right, size: 18, color: SariColors.muted),
                      ],
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

// ----------------------------------------------------
// 3. INVENTORY SCREEN (Paninda)
// ----------------------------------------------------
class InventoryScreen extends StatefulWidget {
  final VoidCallback onRefreshNeeded;
  const InventoryScreen({super.key, required this.onRefreshNeeded});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _products = [];
  String _filter = 'all'; // 'all', 'low', 'categories'

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
    final lowProds = _products.where((p) => p.isLowStock).toList();

    List<Product> shown = _products;
    if (_filter == 'low') shown = lowProds;

    return Scaffold(
      backgroundColor: SariColors.cream,
      appBar: AppBar(
        title: const Text('Paninda sa Tindahan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: SariColors.orange, size: 26),
            tooltip: 'Snap & Track',
            onPressed: _openCameraScanner,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Filter Chips
          Row(
            children: [
              SariFilterChip(
                label: 'Lahat (${_products.length})',
                isSelected: _filter == 'all',
                onTap: () => setState(() => _filter = 'all'),
              ),
              const SizedBox(width: 8),
              SariFilterChip(
                label: 'Low Stock (${lowProds.length})',
                isSelected: _filter == 'low',
                onTap: () => setState(() => _filter = 'low'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Product List
          if (shown.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: SariTheme.cardDecoration(),
              child: const Center(
                child: Text('Walang paninda na tumutugma.', style: TextStyle(color: SariColors.muted)),
              ),
            )
          else
            Container(
              decoration: SariTheme.cardDecoration(),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shown.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final p = shown[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: p.isLowStock ? SariColors.redSoft : SariColors.orangeSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: p.isLowStock ? SariColors.red : SariColors.orangeDark,
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SariColors.ink),
                    ),
                    subtitle: Text(
                      '${p.category} • Benta: ${currency.format(p.sellPrice)} (Puhunan: ${currency.format(p.buyPrice)})',
                      style: const TextStyle(color: SariColors.muted, fontSize: 11),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20, color: SariColors.muted),
                          onPressed: () async {
                            await DatabaseHelper.instance.updateProductQuantity(p.id!, -1);
                            widget.onRefreshNeeded();
                            loadProducts();
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: p.isLowStock ? SariColors.redSoft : SariColors.greenSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${p.quantity}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: p.isLowStock ? SariColors.red : SariColors.green,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20, color: SariColors.green),
                          onPressed: () async {
                            await DatabaseHelper.instance.updateProductQuantity(p.id!, 1);
                            widget.onRefreshNeeded();
                            loadProducts();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),

          // Bottom CTA Pill Button
          SariPillButton(
            icon: Icons.camera_alt_rounded,
            onPressed: _openCameraScanner,
            child: const Text('I-scan ang shelf'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// 4. SARI AI CHAT SCREEN
// ----------------------------------------------------
class SariAiChatScreen extends StatefulWidget {
  const SariAiChatScreen({super.key});

  @override
  State<SariAiChatScreen> createState() => _SariAiChatScreenState();
}

class _SariAiChatScreenState extends State<SariAiChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'sari',
      'text': 'Magandang araw! Ako si Sari, ang iyong on-device AI tindera. Magtanong ka tungkol sa benta, utang, o paubos na paninda!'
    }
  ];

  static const List<String> suggestions = [
    "Kumikita ba ako ngayon?",
    "Anong pinaka-mabenta this week?",
    "Magkano utang lahat?",
    "Sino matagal na hindi nagbabayad?",
    "Ano kailangan i-restock?",
  ];

  Future<void> _askQuestion(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    _chatController.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': clean});
    });

    _scrollToBottom();

    final reply = await LlamaService.instance.askSari(clean);

    setState(() {
      _messages.add({'role': 'sari', 'text': reply});
    });

    _scrollToBottom();
    SpeechService.instance.speak(reply);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SariColors.cream,
      appBar: AppBar(
        title: const Row(
          children: [
            SariMascot(pose: SariPose.face, size: 32),
            SizedBox(width: 10),
            Text('Sari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 8),
            Chip(
              label: Text('100% Offline', style: TextStyle(fontSize: 10, color: SariColors.green, fontWeight: FontWeight.bold)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];
                final isSari = m['role'] == 'sari';

                if (isSari) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SariMascot(pose: SariPose.face, size: 36),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                              border: Border.all(color: SariColors.border),
                              boxShadow: const [
                                BoxShadow(color: Color(0x0A78481E), blurRadius: 8, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Text(
                              m['text']!,
                              style: const TextStyle(
                                color: SariColors.ink,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        color: SariColors.orange,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x18F26B1D), blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        m['text']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          // Suggestion Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: SariColors.cream,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: suggestions.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: SariColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      label: Text(s, style: const TextStyle(fontSize: 12, color: SariColors.ink)),
                      onPressed: () => _askQuestion(s),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Composer Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: SariColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    onSubmitted: _askQuestion,
                    decoration: InputDecoration(
                      hintText: 'Magsulat o magtanong...',
                      hintStyle: const TextStyle(color: SariColors.muted, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: SariColors.cream,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(color: SariColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(color: SariColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(color: SariColors.orange),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: SariColors.orange,
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: () => _askQuestion(_chatController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
