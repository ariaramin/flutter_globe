import 'package:flutter/material.dart';
import 'globe_theme.dart';

/// An animated widget that smoothly interpolates between [GlobeTheme] instances
/// when the target [theme] changes.
class GlobeThemeTransition extends ImplicitlyAnimatedWidget {
  /// Creates a theme transition widget.
  const GlobeThemeTransition({
    super.key,
    required this.theme,
    required this.builder,
    super.duration = const Duration(milliseconds: 500),
    super.curve = Curves.easeOutCubic,
  });

  /// The target globe theme to animate towards.
  final GlobeTheme theme;

  /// Builder callback that receives the smoothly interpolated [GlobeTheme].
  final Widget Function(BuildContext context, GlobeTheme interpolatedTheme)
      builder;

  @override
  AnimatedWidgetBaseState<GlobeThemeTransition> createState() =>
      _GlobeThemeTransitionState();
}

class _GlobeThemeTransitionState
    extends AnimatedWidgetBaseState<GlobeThemeTransition> {
  _GlobeThemeTween? _themeTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _themeTween = visitor(
      _themeTween,
      widget.theme,
      (dynamic value) => _GlobeThemeTween(begin: value as GlobeTheme),
    ) as _GlobeThemeTween?;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _themeTween?.evaluate(animation) ?? widget.theme;
    return widget.builder(context, currentTheme);
  }
}

class _GlobeThemeTween extends Tween<GlobeTheme> {
  _GlobeThemeTween({super.begin});

  @override
  GlobeTheme lerp(double t) {
    final b = begin ?? end ?? const GlobeTheme();
    final e = end ?? begin ?? const GlobeTheme();
    return GlobeTheme.lerp(b, e, t);
  }
}
