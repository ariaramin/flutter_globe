/// Projection modes for rendering the 3D globe to the 2D canvas.
enum GlobeProjection {
  /// Perspective projection with natural 3D depth and foreshortening.
  perspective,

  /// Orthographic projection with parallel rays, simulating a distant telephoto view.
  orthographic,
}
