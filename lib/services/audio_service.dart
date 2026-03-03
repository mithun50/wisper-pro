import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

class AudioService {
  /// Extracts audio from video as 16kHz mono PCM WAV.
  /// Returns the path to the temporary WAV file.
  static Future<String> extractAudio(String videoPath) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/${AppConstants.tempAudioFileName}';

    // Delete existing temp file if any
    final existing = File(outputPath);
    if (await existing.exists()) {
      await existing.delete();
    }

    final command = AppConstants.ffmpegCommand
        .replaceAll('{input}', videoPath)
        .replaceAll('{output}', outputPath);

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getLogsAsString();
      throw Exception('FFmpeg failed (code $returnCode): $logs');
    }

    return outputPath;
  }

  /// Deletes the temporary audio file.
  static Future<void> cleanup() async {
    final tempDir = await getTemporaryDirectory();
    final file =
        File('${tempDir.path}/${AppConstants.tempAudioFileName}');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
