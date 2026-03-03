import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/material.dart';

import '../models/transcription_segment.dart';
import '../models/whisper_model_info.dart';
import '../services/audio_service.dart';
import '../services/file_service.dart';
import '../services/srt_service.dart';
import '../services/whisper_service.dart';
import 'result_screen.dart';

enum _ProcessingStage {
  extractAudio,
  initModel,
  transcribe,
  generateSrt,
}

class ProcessingScreen extends StatefulWidget {
  final String videoPath;
  final String videoFileName;
  final WhisperModelInfo modelInfo;
  final String language;

  const ProcessingScreen({
    super.key,
    required this.videoPath,
    required this.videoFileName,
    required this.modelInfo,
    required this.language,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  _ProcessingStage _currentStage = _ProcessingStage.extractAudio;
  String? _errorMessage;
  bool _cancelled = false;
  final _whisperService = WhisperService();

  static const _stageLabels = {
    _ProcessingStage.extractAudio: 'Extracting audio...',
    _ProcessingStage.initModel: 'Downloading / initializing model...',
    _ProcessingStage.transcribe: 'Transcribing audio...',
    _ProcessingStage.generateSrt: 'Generating SRT file...',
  };

  static final _stageIcons = {
    _ProcessingStage.extractAudio: Icons.audio_file,
    _ProcessingStage.initModel: Icons.download,
    _ProcessingStage.transcribe: Icons.record_voice_over,
    _ProcessingStage.generateSrt: Icons.subtitles,
  };

  @override
  void initState() {
    super.initState();
    _runPipeline();
  }

  @override
  void dispose() {
    _cancelled = true;
    FFmpegKit.cancel();
    super.dispose();
  }

  void _updateStage(_ProcessingStage stage) {
    if (!mounted || _cancelled) return;
    setState(() => _currentStage = stage);
  }

  Future<void> _runPipeline() async {
    try {
      // Stage 1: Extract audio
      _updateStage(_ProcessingStage.extractAudio);
      final audioPath = await AudioService.extractAudio(widget.videoPath);
      if (_cancelled) return;

      // Stage 2: Init model
      _updateStage(_ProcessingStage.initModel);
      await _whisperService.initModel(widget.modelInfo);
      if (_cancelled) return;

      // Stage 3: Transcribe
      _updateStage(_ProcessingStage.transcribe);
      final List<TranscriptionSegment> segments =
          await _whisperService.transcribe(
        audioPath: audioPath,
        language: widget.language,
      );
      if (_cancelled) return;

      // Stage 4: Generate SRT
      _updateStage(_ProcessingStage.generateSrt);
      final srtContent = SrtService.generate(segments);
      final srtPath = await FileService.saveSrt(
        srtContent: srtContent,
        videoFileName: widget.videoFileName,
      );

      // Cleanup temp audio
      await AudioService.cleanup();

      if (!mounted) return;

      // Navigate to result
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            segments: segments,
            srtContent: srtContent,
            srtPath: srtPath,
          ),
        ),
      );
    } catch (e) {
      // Cleanup on error
      await AudioService.cleanup();
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: _errorMessage != null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Processing in progress...')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Processing'),
          automaticallyImplyLeading: _errorMessage != null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child:
              _errorMessage != null ? _buildError(theme) : _buildProgress(theme),
        ),
      ),
    );
  }

  Widget _buildProgress(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 32),
        Text(
          _stageLabels[_currentStage]!,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        // Stage indicators
        ..._ProcessingStage.values.map((stage) {
          final isComplete = stage.index < _currentStage.index;
          final isCurrent = stage == _currentStage;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(
                  isComplete
                      ? Icons.check_circle
                      : isCurrent
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                  color: isComplete
                      ? Colors.green
                      : isCurrent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Icon(
                  _stageIcons[stage],
                  size: 20,
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _stageLabels[stage]!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isCurrent ? FontWeight.bold : null,
                      color: isComplete || isCurrent
                          ? null
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Processing Failed',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
