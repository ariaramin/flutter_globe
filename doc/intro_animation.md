# Intro animation

The reference preset is enabled by default. Use it to reveal a new scene, not on every data update.

```dart
const Globe(introAnimation: GlobeIntroAnimations.reference);
```

```dart
const Globe(introAnimation: GlobeIntroAnimation(
  duration: Duration(seconds: 2),
  scaleFrom: 0.85, opacityFrom: 0,
  overshoot: 1, markerDelay: Duration(milliseconds: 300),
  arcDelay: Duration(milliseconds: 600),
  autoRotateDelay: Duration(milliseconds: 900),
));
```

Other presets are `gentle`, `spring`, and `none`. The `reactBits` name is a compatibility alias for `reference`, not an affiliation or parity claim.

Zero or negative duration is treated as an instant entrance by the timeline. Delays at or beyond the duration resolve at the end without dividing by zero. `revealMarkers: false`/`revealArcs: false` bypass those staged reveals; they do not disable the layer's ongoing animation. `autoRotateOnComplete: false` prevents the intro handoff from starting idle rotation.

To replay an intro, give the Globe a new key. Theme changes retain progress. For reduced motion, `Globe` skips the intro, freezes the scene clock, and prevents idle rotation and momentum. Caller-started controller animations should use zero duration when reduced motion is enabled, as in the [controller example](controller.md).
