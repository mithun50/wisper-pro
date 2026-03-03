import 'package:whisper_flutter_new/whisper_flutter_new.dart';

import '../models/transcription_segment.dart';
import '../models/whisper_model_info.dart';

class WhisperService {
  static final WhisperService _instance = WhisperService._();
  factory WhisperService() => _instance;
  WhisperService._();

  Whisper? _whisper;
  String? _loadedModel;

  /// Initializes the Whisper model. Downloads from HuggingFace if not cached.
  Future<void> initModel(WhisperModelInfo modelInfo) async {
    if (_loadedModel == modelInfo.name && _whisper != null) return;

    _whisper = Whisper(
      model: _resolveModel(modelInfo.name),
      downloadHost:
          'https://huggingface.co/ggerganov/whisper.cpp/resolve/main',
    );
    _loadedModel = modelInfo.name;
  }

  /// Transcribes the audio file and returns a list of segments.
  Future<List<TranscriptionSegment>> transcribe({
    required String audioPath,
    required String language,
  }) async {
    if (_whisper == null) {
      throw StateError('Whisper model not initialized. Call initModel first.');
    }

    final response = await _whisper!.transcribe(
      transcribeRequest: TranscribeRequest(
        audio: audioPath,
        isNoTimestamps: false,
        splitOnWord: true,
        language: language,
      ),
    );

    final segments = <TranscriptionSegment>[];
    final rawSegments = response.segments;

    if (rawSegments != null) {
      for (final segment in rawSegments) {
        segments.add(
          TranscriptionSegment(
            start: segment.fromTs,
            end: segment.toTs,
            text: segment.text.trim(),
          ),
        );
      }
    }

    return segments;
  }

  static WhisperModel _resolveModel(String name) {
    switch (name) {
      case 'tiny':
        return WhisperModel.tiny;
      case 'small':
        return WhisperModel.small;
      default:
        return WhisperModel.tiny;
    }
  }
}
