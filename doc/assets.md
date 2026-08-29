# Documentation assets

The project maintainer supplied `assets/readme/banner.png` on 2026-08-29 as the canonical Flutter Globe banner. It is a 1915 x 821 RGB PNG with SHA-256 `9f5c361ef0c35dc007f781ff8f25a2693ffcc10663516f3191e0bfc3608b733f`.

The previous generated banner was replaced rather than retained. The README also contains two captures from the real release example:

- `assets/readme/previews/showcase.png`: 1440 x 900 desktop showcase.
- `assets/readme/previews/mobile.png`: 390 x 844 logical viewport captured at 2x scale.

The preview images were captured from `flutter build web --release` through local headless Chrome. They are documentation evidence, not benchmark results.

## Geographic data

The bundled point cloud is generated from Natural Earth 1:110m public-domain land polygons. See [`ATTRIBUTION.md`](../ATTRIBUTION.md) and `tool/generate_land_data.py` for the source URL, checksum, terms, and reproducible generator.
