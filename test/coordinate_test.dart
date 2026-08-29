import 'dart:math' as math;
import 'package:flutter_globe/flutter_globe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('external coordinates validate finite values and normalize longitude',
      () {
    expect(GlobeCoordinate.normalized(latitude: 10, longitude: 540).longitude,
        -180);
    for (final value in [double.nan, double.infinity, -double.infinity]) {
      expect(() => GlobeCoordinate.normalized(latitude: value, longitude: 0),
          throwsArgumentError);
      expect(() => GlobeCoordinate.normalized(latitude: 0, longitude: value),
          throwsArgumentError);
    }
    expect(() => GlobeCoordinate.normalized(latitude: 91, longitude: 0),
        throwsArgumentError);
  });

  group('GlobeCoordinate Models', () {
    test('coordinate radian conversions', () {
      const coord = GlobeCoordinate(latitude: 45.0, longitude: 90.0);
      expect(coord.latitudeRadians, closeTo(math.pi / 4.0, 1e-6));
      expect(coord.longitudeRadians, closeTo(math.pi / 2.0, 1e-6));
    });

    test('validates latitude bounds', () {
      expect(
        () => GlobeCoordinate(latitude: 95.0, longitude: 0.0),
        throwsAssertionError,
      );
      expect(
        () => GlobeCoordinate(latitude: -95.0, longitude: 0.0),
        throwsAssertionError,
      );
    });

    test('angular distance between coordinates', () {
      const sf = GlobeCoordinate(latitude: 37.7749, longitude: -122.4194);
      const london = GlobeCoordinate(latitude: 51.5074, longitude: -0.1278);

      final distance = sf.angularDistanceTo(london);
      // Great circle distance from SF to London is ~8618 km => angle ~ 1.353 radians
      expect(distance, closeTo(1.353, 0.05));
    });

    test('equality and hashcode', () {
      const c1 = GlobeCoordinate(latitude: 37.77, longitude: -122.41);
      const c2 = GlobeCoordinate(latitude: 37.77, longitude: -122.41);
      const c3 = GlobeCoordinate(latitude: 40.71, longitude: -74.00);

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1, isNot(equals(c3)));
    });
  });
}
