class AppConstants {
  AppConstants._();

  static const String appName = 'Wisper Pro';

  // HuggingFace model download base URL
  static const String huggingFaceBaseUrl =
      'https://huggingface.co/ggerganov/whisper.cpp/resolve/main';

  // FFmpeg command for audio extraction: 16kHz mono PCM WAV
  static const String ffmpegCommand =
      '-i {input} -vn -acodec pcm_s16le -ar 16000 -ac 1 -y {output}';

  // Default settings
  static const String defaultModel = 'tiny';
  static const String defaultLanguage = 'auto';

  // Temp audio file name
  static const String tempAudioFileName = 'wisper_temp_audio.wav';

  // SRT output directory name
  static const String srtOutputDir = 'WisperPro';

  // Video file extensions for picker
  static const List<String> videoExtensions = [
    'mp4',
    'mkv',
    'avi',
    'mov',
    'webm',
    'flv',
    'wmv',
    '3gp',
    'm4v',
  ];
}
