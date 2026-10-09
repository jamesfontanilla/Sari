import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  String? get currentPath => _currentRecordingPath;

  Future<bool> startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) return false;

    final tempDir = await getTemporaryDirectory();
    _currentRecordingPath = '${tempDir.path}/sari_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 16000, // 16kHz is optimal for Whisper
      ),
      path: _currentRecordingPath!,
    );

    _isRecording = true;
    return true;
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    final path = await _audioRecorder.stop();
    _isRecording = false;
    return path;
  }

  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}
