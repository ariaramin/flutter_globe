# Release readiness report

**Status: published with notes.** Flutter Globe 1.0.2 is available on pub.dev and GitHub. This patch refreshes documentation assets without changing the package API or runtime behavior.

## Release scope

- Stable public entry point: `lib/flutter_globe.dart`.
- Primary APIs: `Globe`, `GlobeController`, `GlobeCoordinate`, `GlobeTheme`, `GlobeSkins`, markers, arcs, layers, intro animation, and camera tours.
- `GlobeTheme` is the single public appearance model. Pre-release `GlobeStyle` and `GlobeAtmosphere` types are not exported.
- Shortcut interaction arguments override the corresponding `GlobeInteractionConfig` values when supplied; `interactive` remains the master switch.
- The example includes Showcase, Skins, Arcs, Markers, Data Layers, Playground, and Benchmarks. It has no Tour tab.
- The deterministic benchmark uses seed `1337`, named workloads, engine frame timings, and JSON export. It does not claim GPU time, memory use, or device-independent FPS.

## Assets and data

- `assets/readme/banner.png` is the maintainer-supplied 1915 x 821 project banner. The README also includes two desktop captures from the real release example, documented in [assets](assets.md).
- The bundled land point cloud contains 2,594 deterministic samples generated from Natural Earth 1:110m public-domain land polygons. Source URL, checksum, terms, and generator are recorded in [`ATTRIBUTION.md`](../ATTRIBUTION.md).
- The package contains no remote runtime map request, API key, or proprietary map dataset.

## Verification record

| Check | Result |
| --- | --- |
| Flutter SDK | Flutter 3.47.0 stable / Dart 3.13.0. |
| `dart format --output=none --set-exit-if-changed .` | Passed after release edits. |
| `flutter analyze` | Passed with no issues. |
| `flutter test` | Passed: 73 tests. |
| `python3 tool/check_docs.py` | Passed: local links and 29 Dart examples. |
| `cd example && flutter test` | Passed: 2 tests, including 390 x 844 navigation/overflow coverage. |
| `cd example && flutter build web --release` | Passed. Flutter emitted advisory Wasm and unused Cupertino icon-font messages; neither failed the build. |
| `dart doc` | Passed: 1 public library, 0 warnings, 0 errors. |
| `dart pub publish --dry-run` | Passed: package archive validated with 0 warnings. |
| Browser inspection | Passed at desktop and 390 x 844 mobile sizes with no browser console warnings or errors. |

## Compatibility and remaining verification

- Web is the platform verified locally for this release.
- CI passed Flutter 3.27.4, the declared minimum line, and Flutter 3.47.0 before the GitHub release was tagged.
- Android, iOS, macOS, Windows, and Linux have not been built in this checkout.
- No physical-device performance profile, GPU measurement, screen-reader session, or complete large-text matrix was recorded. Canvas portability and automated tests do not substitute for those checks.
- Private vulnerability reporting is enabled on the public GitHub repository.

## Release commands

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
python3 tool/check_docs.py
dart doc
dart pub publish --dry-run
cd example
flutter test
flutter build web --release
```

Published artifacts: [pub.dev](https://pub.dev/packages/flutter_globe), [GitHub repository](https://github.com/ariaramin/flutter_globe), and [v1.0.0 release](https://github.com/ariaramin/flutter_globe/releases/tag/v1.0.0).
