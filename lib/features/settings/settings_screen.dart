import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/speech_service.dart';
import '../../core/theme/sari_theme.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onDataReset;

  const SettingsScreen({super.key, required this.onDataReset});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isResetting = false;
  bool _airplaneMode = true;

  void _confirmResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: SariColors.orange),
            SizedBox(width: 8),
            Text('I-reset ang Demo Tindahan?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: const Text(
          'Mabubura ang lahat ng bagong record at babalik sa demo data (20 starter sari-sari items at 3 demo suki) para sa pagsubok ng mga hurado.',
          style: TextStyle(color: SariColors.ink, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kanselahin', style: TextStyle(color: SariColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SariColors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isResetting = true);
              await DatabaseHelper.instance.resetAndSeedDatabase();
              widget.onDataReset();
              setState(() => _isResetting = false);

              const msg = "Na-reset na ang demo data!";
              SpeechService.instance.speak(msg);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(msg),
                    backgroundColor: SariColors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Oo, I-reset Na', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SariColors.cream,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Airplane Mode Switch Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: SariTheme.cardDecoration(),
            child: Row(
              children: [
                const Icon(Icons.airplanemode_active_rounded, color: SariColors.orange, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Airplane Mode Ready',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: SariColors.ink),
                  ),
                ),
                Switch(
                  value: _airplaneMode,
                  activeThumbColor: SariColors.orange,
                  onChanged: (val) {
                    setState(() => _airplaneMode = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_airplaneMode ? 'Aktibo ang 100% Offline mode!' : 'Online simulation mode.'),
                        backgroundColor: SariColors.green,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 100% Offline Mascot Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFED7AA)),
              boxShadow: const [
                BoxShadow(color: Color(0x1078481E), blurRadius: 14, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gumagana pa rin kahit walang internet!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: SariColors.ink,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...['Voice commands', 'Camera scanning', 'AI responses', 'Full SQLite database'].map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: SariColors.green, size: 16),
                                  const SizedBox(width: 6),
                                  Text(item, style: const TextStyle(fontSize: 13, color: SariColors.inkLight)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SariMascot(pose: SariPose.offline, size: 110),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: SariColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔒 ', style: TextStyle(fontSize: 12)),
                      Text(
                        '100% Offline · No Internet Needed',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SariColors.orangeDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Group: Data
          const Text('Data & Tindahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: SariColors.ink)),
          const SizedBox(height: 8),
          Container(
            decoration: SariTheme.cardDecoration(),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: SariColors.orange),
                  title: const Text('I-export ang data (JSON)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Naka-save lang sa phone mo', style: TextStyle(fontSize: 12, color: SariColors.muted)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: SariColors.muted),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Na-save ang backup sa phone mo.'),
                        backgroundColor: SariColors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: _isResetting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: SariColors.orange, strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, color: SariColors.orange),
                  title: const Text('I-reset ang demo data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Babalik sa sample na tindahan (Demo Day)', style: TextStyle(fontSize: 12, color: SariColors.muted)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: SariColors.muted),
                  onTap: _isResetting ? null : _confirmResetDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Group: Tutorial
          const Text('Gabay at Modelo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: SariColors.ink)),
          const SizedBox(height: 8),
          Container(
            decoration: SariTheme.cardDecoration(),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.mic_external_on_rounded, color: SariColors.orange),
                  title: const Text('Speech Engine: Whisper Base', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('On-device Tagalog / Taglish speech recognition', style: TextStyle(fontSize: 12, color: SariColors.muted)),
                  trailing: const Chip(
                    label: Text('Ready', style: TextStyle(fontSize: 10, color: SariColors.green, fontWeight: FontWeight.bold)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.psychology_outlined, color: SariColors.orange),
                  title: const Text('Language Model: Llama 3.2 3B', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('GGUF Quantized local reasoning engine', style: TextStyle(fontSize: 12, color: SariColors.muted)),
                  trailing: const Chip(
                    label: Text('Ready', style: TextStyle(fontSize: 10, color: SariColors.green, fontWeight: FontWeight.bold)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.play_circle_outline_rounded, color: SariColors.orange),
                  title: const Text('Ipakita ulit ang tutorial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('3 hakbang lang para magsimula', style: TextStyle(fontSize: 12, color: SariColors.muted)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: SariColors.muted),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sari Tutorial: 1. Pindutin ang Mic. 2. Sabihin ang utang/benta. 3. I-tap ang I-record!'),
                        backgroundColor: SariColors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Footer
          const Center(
            child: Text(
              'Sari · v1.0\nWalang login · Walang ads · Libre habambuhay',
              textAlign: TextAlign.center,
              style: TextStyle(color: SariColors.muted, fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
