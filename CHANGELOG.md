# Changelog

## 1.0.1 — 2026-08-29

### Documentation

- Replaced the README banner with the maintainer-supplied Flutter Globe artwork.
- Simplified the README and added real desktop and responsive mobile example previews.

## 1.0.0 — 2026-08-29

### Added

- Stable interactive `Globe`, `GlobeController`, geographic marker/arc, theme, intro-animation, tour, projection, and custom-layer APIs.
- Perspective and orthographic projection, drag rotation, pinch zoom, momentum, automatic rotation, and reduced-motion behavior.
- Twenty-four named themes, theme interpolation, grid, heatmap, label, region, route, particle, and day/night layers.
- Seven-destination example with a live code-generating playground.
- Seeded baseline, typical, dense, stress, and developer-extreme benchmark profiles with JSON export and a frame-time timeline.

### Improved

- Hardened empty/tiny layouts, coordinate input, projection-aware hit testing, controller swaps, tour cancellation, zero-duration animation, and disposal paths.
- Made widget interaction shortcuts override grouped theme values predictably.
- Made quality profiles control land sampling, arc subdivision, and particle density; `auto` selects from rendered size.
- Removed overlapping or nonfunctional pre-release style, effect, and layer-hit APIs before the stable boundary.
- Replaced the unverified land point cloud with reproducible Natural Earth public-domain derived data.

### Documentation

- Added complete integration, customization, interaction, accessibility, performance, benchmark, migration, troubleshooting, and contribution documentation.
- Added DartDoc validation, community issue forms, CI, security guidance, release notes, attribution, and one generated README banner.

### Compatibility notes

- Auto-rotation speed is radians per second without the former hidden multiplier.
- Use `GlobeTheme` and `GlobeAtmosphereStyle`; pre-release `GlobeStyle` and `GlobeAtmosphere` are no longer public.
- Use `GlobeCoordinate.normalized` for runtime validation and longitude wrapping of external data.
