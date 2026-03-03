import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  runApp(const WisperProApp());
}

Future<void> _requestPermissions() async {
  await [
    Permission.videos,
    Permission.storage,
  ].request();
}
