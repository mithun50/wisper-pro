# Wisper Pro

Video to SRT subtitle generator powered by Whisper AI. Runs entirely on-device — no internet required after model download.

## Features

- **Video to SRT** — Pick any video, generate accurate subtitle files
- **On-device AI** — Whisper.cpp runs locally, no cloud API needed
- **Two model sizes** — Tiny (75 MB, fast) or Small (466 MB, accurate)
- **99 languages** — All Whisper-supported languages plus auto-detect
- **Share & export** — Copy SRT to clipboard or share via system sheet

## How It Works

```
Select video → Extract audio (FFmpeg) → Whisper transcription → SRT file → Save/Share
```

1. Pick a video file from your device
2. Choose a Whisper model (Tiny for speed, Small for accuracy)
3. Select language or use auto-detect
4. Tap "Generate SRT" — the app extracts audio, runs Whisper, and produces an SRT file
5. Preview, copy, or share the result

## Tech Stack

- **Flutter** with Material 3 dark theme
- **whisper_flutter_new** — Whisper.cpp FFI bindings
- **ffmpeg_kit_flutter_new** — Audio extraction from video
- **file_picker** — Video file selection
- **share_plus** — System share sheet

## Building

### GitHub Actions (Recommended)

Push to `main` branch — GitHub Actions automatically builds the release APK.

To create a release, push a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Local Build

```bash
flutter pub get
flutter build apk --release
```

Requires: Flutter SDK (stable), Java 17, Android SDK (minSdk 24)

## Project Structure

```
lib/
├── main.dart                    # Entry point, permissions
├── app.dart                     # MaterialApp config, dark theme
├── constants/
│   ├── app_constants.dart       # URLs, defaults
│   └── whisper_languages.dart   # 99 language codes
├── models/
│   ├── transcription_segment.dart
│   └── whisper_model_info.dart
├── services/
│   ├── audio_service.dart       # FFmpeg audio extraction
│   ├── whisper_service.dart     # Model download & transcription
│   ├── srt_service.dart         # SRT format generation
│   └── file_service.dart        # File pick, save, share
└── screens/
    ├── home_screen.dart         # Video picker, settings
    ├── processing_screen.dart   # 4-stage pipeline progress
    └── result_screen.dart       # SRT preview & sharing
```

## License

MIT
