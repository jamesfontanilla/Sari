import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/speech_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onDataReset;

  const SettingsScreen({super.key, required this.onDataReset});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isResetting = false;

  void _confirmResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: Color(0xFFEA580C)),
            SizedBox(width: 8),
            Text('I-reset ang Demo Tindahan?'),
          ],
        ),
        content: const Text(
          'Ibabalik nito ang 20 starter sari-sari items at 3 demo suki (Mang Juan, Aling Rosa, Kuya Jojo) sa kanilang orihinal na halaga para sa pagsusulit ng mga hurado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kanselahin'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isResetting = true);
              await DatabaseHelper.instance.resetAndSeedDatabase();
              widget.onDataReset();
              setState(() => _isResetting = false);

              const msg = "Na-reset na ang tindahan sa demo state!";
              SpeechService.instance.speak(msg);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(msg),
                    backgroundColor: Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Oo, I-reset Na'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mga Setting at Demo Tools', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Demo Day Quick Reset Banner
          Card(
            color: const Color(0xFFFFFBEB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFFCD34D)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Demo Day Tools (SM Makati)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF92400E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gamitin ang button na ito upang i-reset ang datos bago humarap sa bawat hurado.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF78350F)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isResetting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: const Text(
                      'I-reset ang Demo Tindahan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onPressed: _isResetting ? null : _confirmResetDialog,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text('Katayuan ng On-Device AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Offline Status Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: const Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(Icons.airplanemode_active_rounded, color: Color(0xFF16A34A)),
                  ),
                  title: Text('100% Offline / Airplane Mode Ready', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Walang cloud API calls. Lahat ng parsing at database ay nasa mismong telepono.'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFFEF3C7),
                    child: Icon(Icons.graphic_eq_rounded, color: Color(0xFFD97706)),
                  ),
                  title: Text('Speech Model: Whisper Base (141 MB)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('On-device speech recognition para sa Tagalog at Taglish.'),
                  trailing: Chip(label: Text('Installed', style: TextStyle(fontSize: 11, color: Colors.green))),
                ),
                Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFE0E7FF),
                    child: Icon(Icons.psychology_rounded, color: Color(0xFF4338CA)),
                  ),
                  title: Text('Language Model: Llama 3.2 3B (1.9 GB)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Local GGUF quantized model para sa business insights.'),
                  trailing: Chip(label: Text('Installed', style: TextStyle(fontSize: 11, color: Colors.green))),
                ),
                Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFF3E8FF),
                    child: Icon(Icons.camera_alt_rounded, color: Color(0xFF7E22CE)),
                  ),
                  title: Text('Vision Engine: Snap & Track', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Barcode at shelf visual detection na konektado sa SQLite.'),
                  trailing: Chip(label: Text('Active', style: TextStyle(fontSize: 11, color: Colors.green))),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text('Tungkol sa Proyekto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🏪 Sari — Sari-Sari Business Brain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('AppBuildersPH Hackathon 2026 • Local AI Theme', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  SizedBox(height: 12),
                  Text(
                    'Binuo para sa 1.3 milyong may-ari ng sari-sari store sa Pilipinas na nangangailangan ng maaasahan, libre, at 100% offline na AI assistant sa kanilang bulsa.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
