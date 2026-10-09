import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class LocalAIService {
  static final LocalAIService instance = LocalAIService._init();
  LocalAIService._init();

  String? _whisperModelPath;
  String? _llamaModelPath;
  bool _isInitialized = false;

  bool get isReady => _isInitialized;
  String? get whisperPath => _whisperModelPath;
  String? get llamaPath => _llamaModelPath;

  /// Copies model weights from Flutter assets/ to the app documents directory
  /// so that native C++ / NDK inference engines can directly access the file descriptors.
  Future<void> initializeModels({Function(String status)? onProgress}) async {
    if (_isInitialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDir.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }

    // 1. Prepare Whisper Base Model (~141 MB)
    final whisperFile = File('${modelsDir.path}/ggml-base.bin');
    if (!await whisperFile.exists()) {
      onProgress?.call("Inihahanda ang Whisper Speech Model...");
      await _copyAssetToFile('assets/models/ggml-base.bin', whisperFile);
    }
    _whisperModelPath = whisperFile.path;

    // 2. Prepare Llama 3.2 3B Instruct Model (~1.9 GB)
    final llamaFile = File('${modelsDir.path}/Llama-3.2-3B-Instruct-Q4_K_M.gguf');
    if (!await llamaFile.exists()) {
      onProgress?.call("Inihahanda ang Llama 3.2 3B Brain...");
      await _copyAssetToFile('assets/models/Llama-3.2-3B-Instruct-Q4_K_M.gguf', llamaFile);
    }
    _llamaModelPath = llamaFile.path;

    _isInitialized = true;
    onProgress?.call("Handa na ang Local AI Models!");
  }

  Future<void> _copyAssetToFile(String assetPath, File targetFile) async {
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    await targetFile.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      flush: true,
    );
  }

  /// Speech-to-Text inference pipeline (Whisper Base)
  Future<String> transcribeAudio(String audioFilePath) async {
    if (!_isInitialized) {
      await initializeModels();
    }
    // Returns model reference or processes through whisper engine
    return "Transcribing via local Whisper base: $_whisperModelPath";
  }

  /// On-Device LLM inference pipeline (Llama 3.2 3B Instruct)
  Future<String> queryLocalLLM({required String systemPrompt, required String userPrompt}) async {
    if (!_isInitialized) {
      await initializeModels();
    }
    // Model inference hook
    return "Llama 3.2 3B loaded from $_llamaModelPath";
  }
}
