# Troubleshooting

| Symptom | Check |
| --- | --- |
| Unbounded-size error / blank globe | Wrap it in a bounded `SizedBox` or `AspectRatio`; use positive dimensions. |
| Invalid coordinate assertion | Latitude must be [-90, 90], longitude [-180, 180]. Use `GlobeCoordinate.normalized` for external data. |
| Controller animation fails on disposal | Dispose your external controller before the owning State's `super.dispose`; do not reuse a disposed ticker provider. |
| Skin change has little effect | Check [supported fields and precedence](customization.md); do not combine legacy `style` with `theme`. |
| Marker not tappable | Check whether it is on the front hemisphere and `interactive` is enabled. Labels do not expand the marker's hit target. |
| Intro will not replay | Replace the Globe's key. Rebuilding with the same State retains its progress. |
| No native benchmark metrics | Web is explicitly unavailable; use a native profile build. A native run with no timing callbacks also reports unavailable. |
| Performance differs from a test | PictureRecorder tests record CPU drawing commands; they do not exercise the display/GPU pipeline. |
| Generated code differs from view | Export is the target theme and sample scene, not live camera state or active theme-transition colors. |
| SDK compilation errors | The old 3.10 claim was incorrect; the package uses newer Color APIs. Use a current Flutter SDK and report `flutter --version`. |

For rendering reports, include the smallest complete widget, platform, pixel ratio, projection, theme, reduced-motion setting, and an unedited screenshot. Remove secrets and private location data before sharing logs.
