# Contributing

Thanks for helping make Flutter Globe useful and reliable. Read [release readiness](doc/release_readiness.md) before publishing or promising compatibility.

## Setup

Use Flutter 3.27 or newer, Dart, and Python 3 for the documentation checker.

```bash
flutter pub get
dart format .
flutter analyze
flutter test
python3 tool/check_docs.py
cd example
flutter pub get
flutter test
flutter run -d chrome
```

For benchmarks, use a native device and `flutter run --profile`, then open Benchmarks. Export JSON and include device/OS, Flutter version, build mode, scene, viewport, pixel ratio, and power conditions. Do not use debug or PictureRecorder numbers as GPU/FPS claims.

## Changes and pull requests

Keep changes focused and retain existing public behavior unless the issue explicitly calls for an API change. Reuse existing models and render boundaries. Keep network/data parsing out of painting and widgets. Dispose tickers, timers, listeners, and native text-layout resources. Treat lists passed to rendering as immutable.

Run the narrowest test that covers the behavior, then the package checks. Add a regression for bugs. For UI changes, include unedited before/after screenshots at desktop and mobile sizes, mention reduced motion and large text, and describe which platforms you actually checked. Do not add benchmark thresholds tied to your workstation to CI.

Document public members with their units, ranges, ownership, and unsupported behavior. Keep snippets executable; `tool/check_docs.py` checks local links and compiles the Markdown Dart examples. Generated API docs can be built with `dart doc` after dependencies are installed.

## Reporting issues

Use the matching bug, feature, performance, visual, or documentation template once this repository is hosted. Include a minimal reproduction rather than a full private application. Remove keys, personal location data, and unrelated logs. Security reports follow [SECURITY.md](SECURITY.md), not public issues.

Security reports must use GitHub private vulnerability reporting rather than public issues.
