import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/whisper_languages.dart';
import '../models/whisper_model_info.dart';
import '../services/file_service.dart';
import 'processing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedVideoPath;
  String? _videoFileName;
  String _selectedModel = AppConstants.defaultModel;
  String _selectedLanguage = AppConstants.defaultLanguage;

  Future<void> _pickVideo() async {
    final path = await FileService.pickVideo();
    if (path != null) {
      setState(() {
        _selectedVideoPath = path;
        _videoFileName = path.split('/').last;
      });
    }
  }

  void _startProcessing() {
    if (_selectedVideoPath == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          videoPath: _selectedVideoPath!,
          videoFileName: _videoFileName!,
          modelInfo: WhisperModelInfo.fromName(_selectedModel),
          language: _selectedLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video picker card
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _pickVideo,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        _selectedVideoPath != null
                            ? Icons.video_file
                            : Icons.video_library_outlined,
                        size: 56,
                        color: _selectedVideoPath != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedVideoPath != null
                            ? _videoFileName!
                            : 'Tap to select a video',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedVideoPath != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tap to change',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Model selection
            Text('Whisper Model', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: WhisperModelInfo.available
                  .map(
                    (m) => ButtonSegment<String>(
                      value: m.name,
                      label: Text(m.displayName),
                    ),
                  )
                  .toList(),
              selected: {_selectedModel},
              onSelectionChanged: (selection) {
                setState(() => _selectedModel = selection.first);
              },
            ),

            const SizedBox(height: 24),

            // Language selection
            Text('Language', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: WhisperLanguages.all.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                }
              },
            ),

            const SizedBox(height: 32),

            // Generate button
            FilledButton.icon(
              onPressed: _selectedVideoPath != null ? _startProcessing : null,
              icon: const Icon(Icons.subtitles),
              label: const Text('Generate SRT'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
