class TranscriptionSegment {
  final Duration start;
  final Duration end;
  final String text;

  const TranscriptionSegment({
    required this.start,
    required this.end,
    required this.text,
  });

  @override
  String toString() => 'TranscriptionSegment($start -> $end: $text)';
}
