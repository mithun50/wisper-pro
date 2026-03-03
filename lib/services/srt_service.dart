import '../models/transcription_segment.dart';

class SrtService {
  SrtService._();

  /// Converts a list of transcription segments to SRT format string.
  static String generate(List<TranscriptionSegment> segments) {
    final buffer = StringBuffer();

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final index = i + 1;

      buffer.writeln(index);
      buffer.writeln(
        '${_formatTimestamp(segment.start)} --> ${_formatTimestamp(segment.end)}',
      );
      buffer.writeln(segment.text);
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Formats a Duration as SRT timestamp: HH:MM:SS,mmm
  static String _formatTimestamp(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds =
        (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$milliseconds';
  }
}
