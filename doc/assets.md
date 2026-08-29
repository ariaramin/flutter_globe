# Documentation asset and provenance

The README uses exactly one visual asset: `assets/readme/banner.png`. It is a 2048×768 PNG generated for this project with the built-in image-generation tool on 2026-08-29. No inherited banner or secondary preview image is retained.

The final generation prompt was:

> Create one final wide 1600×600 isometric hero banner for the open-source Flutter package Flutter Globe, with no subtitle and no other readable text. Central composition: a sophisticated floating isometric globe with dotted point-cloud continents, subtle dark ocean surface, cyan and electric-blue highlights, elegant glowing connection arcs traveling between geographic points, small pulse markers, and a soft atmospheric halo. Surround it with only a few minimal isometric technical interface elements suggesting configuration, data visualization, and rendering controls; keep them abstract and clean, without readable micro-text. Premium modern developer-tool illustration, precise geometric forms, isometric perspective, clean depth, soft shadows, restrained glow, dark navy background, Flutter-inspired cyan and blue palette with subtle violet accents. Technical, polished, futuristic, professional, open-source friendly. Keep the key content centered with generous margins so it remains clear at GitHub README width and on mobile. Avoid photorealistic Earth imagery, cartoon styling, stock-photo aesthetics, excessive UI panels, feature lists, badges, code blocks, multiple globes, watermarks, third-party logos, and clutter. Use no text, or at most only the exact subtle title “Flutter Globe”. This is the only visual banner for the README.

The generated source was copied directly to the final path without compositing or upscaling. The banner is conceptual branding, not a rendering screenshot or performance result.

## Geographic data

The bundled point cloud is generated from Natural Earth 1:110m public-domain land polygons. See [`ATTRIBUTION.md`](../ATTRIBUTION.md) and `tool/generate_land_data.py` for the source URL, checksum, terms, and reproducible generator. No React Bits source code or proprietary assets are included intentionally.
