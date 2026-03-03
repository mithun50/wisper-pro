class WhisperModelInfo {
  final String name;
  final String displayName;
  final String fileName;
  final int sizeInMB;

  const WhisperModelInfo({
    required this.name,
    required this.displayName,
    required this.fileName,
    required this.sizeInMB,
  });

  static const tiny = WhisperModelInfo(
    name: 'tiny',
    displayName: 'Tiny (75 MB)',
    fileName: 'ggml-tiny.bin',
    sizeInMB: 75,
  );

  static const small = WhisperModelInfo(
    name: 'small',
    displayName: 'Small (466 MB)',
    fileName: 'ggml-small.bin',
    sizeInMB: 466,
  );

  static const List<WhisperModelInfo> available = [tiny, small];

  static WhisperModelInfo fromName(String name) {
    return available.firstWhere(
      (m) => m.name == name,
      orElse: () => tiny,
    );
  }
}
