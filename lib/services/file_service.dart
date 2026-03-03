import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_constants.dart';

class FileService {
  FileService._();

  /// Opens file picker for video selection. Returns the file path or null.
  static Future<String?> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    return result?.files.single.path;
  }

  /// Saves SRT content to app documents directory.
  /// Returns the full path of the saved file.
  static Future<String> saveSrt({
    required String srtContent,
    required String videoFileName,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final outputDir = Directory('${docsDir.path}/${AppConstants.srtOutputDir}');

    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    // Replace video extension with .srt
    final baseName = videoFileName.replaceAll(
      RegExp(r'\.[^.]+$'),
      '',
    );
    final srtFileName = '$baseName.srt';
    final outputPath = '${outputDir.path}/$srtFileName';

    final file = File(outputPath);
    await file.writeAsString(srtContent);

    return outputPath;
  }

  /// Shares the SRT file via system share sheet.
  static Future<void> shareSrt(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Wisper Pro - Subtitles',
    );
  }
}
