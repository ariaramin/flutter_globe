# FAQ

**Does it need a 3D engine or API key?** No. Runtime dependencies are Flutter and `meta`. Land dots ship in Dart source; no runtime map requests are made.

**Is it a precise map?** No. Land dots and region clipping are visual approximations. It does not provide borders, routing, geocoding, or a GIS data contract.

**Can I render without markers?** Yes: `const Globe()` uses empty lists. Empty optional layers are also valid.

**Why does disabling auto-rotation leave moving arcs?** Camera rotation and scene animation are independent. Use reduced motion to freeze the scene.

**Why do some preset names look similar?** Presets are palettes and style bundles. Several surface/particle-type fields are retained metadata, not independent effects.

**Is this package published?** Check the `flutter_globe` page on pub.dev for the current published version. This checkout is prepared as version 1.0.0.

**How do I expose locations to assistive technology?** Supply `semanticLabel` and an equivalent Flutter list of actions/details. Canvas markers are not separate semantic nodes.
