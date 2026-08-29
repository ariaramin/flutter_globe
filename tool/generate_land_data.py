#!/usr/bin/env python3
"""Generate the bundled point cloud from Natural Earth public-domain land data."""

import argparse
import hashlib
import json
import math
import urllib.request
from pathlib import Path

SOURCE_URL = (
    "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/"
    "master/geojson/ne_110m_land.geojson"
)
SOURCE_SHA256 = "9e0729ee253ca7d7a5c4ae9395fb1902264c5377c52e224d13dd85010e2835d9"
CANDIDATE_COUNT = 9000


def load_source(source: Path | None) -> dict:
    data = source.read_bytes() if source else urllib.request.urlopen(SOURCE_URL).read()
    digest = hashlib.sha256(data).hexdigest()
    if digest != SOURCE_SHA256:
        raise ValueError(f"Natural Earth source checksum changed: {digest}")
    return json.loads(data)


def polygons(document: dict) -> list[list[list[list[float]]]]:
    result = []
    for feature in document["features"]:
        geometry = feature["geometry"]
        coordinates = geometry["coordinates"]
        result.extend(coordinates if geometry["type"] == "MultiPolygon" else [coordinates])
    return result


def in_ring(longitude: float, latitude: float, ring: list[list[float]]) -> bool:
    inside = False
    previous = ring[-1]
    for current in ring:
        x1, y1 = previous
        x2, y2 = current
        if (y1 > latitude) != (y2 > latitude):
            crossing = (x2 - x1) * (latitude - y1) / (y2 - y1) + x1
            if longitude < crossing:
                inside = not inside
        previous = current
    return inside


def is_land(longitude: float, latitude: float, shapes) -> bool:
    for exterior, holes, bounds in shapes:
        min_x, min_y, max_x, max_y = bounds
        if not (min_x <= longitude <= max_x and min_y <= latitude <= max_y):
            continue
        if in_ring(longitude, latitude, exterior) and not any(
            in_ring(longitude, latitude, hole) for hole in holes
        ):
            return True
    return False


def generate(document: dict) -> list[tuple[float, float, float]]:
    shapes = []
    for polygon in polygons(document):
        exterior, *holes = polygon
        xs = [point[0] for point in exterior]
        ys = [point[1] for point in exterior]
        shapes.append((exterior, holes, (min(xs), min(ys), max(xs), max(ys))))

    golden_angle = math.pi * (3 - math.sqrt(5))
    points = []
    for index in range(CANDIDATE_COUNT):
        latitude_sine = 1 - 2 * (index + 0.5) / CANDIDATE_COUNT
        latitude = math.degrees(math.asin(latitude_sine))
        longitude = math.degrees((index * golden_angle) % (2 * math.pi)) - 180
        if not is_land(longitude, latitude, shapes):
            continue
        lat = math.radians(latitude)
        lon = math.radians(longitude)
        cos_lat = math.cos(lat)
        points.append((cos_lat * math.sin(lon), -math.sin(lat), cos_lat * math.cos(lon)))
    return points


def render(points: list[tuple[float, float, float]]) -> str:
    values = "\n".join(
        f"    {component:.6f}," for point in points for component in point
    )
    return f"""import 'dart:typed_data';
import '../math/vector3.dart';

/// Natural Earth 1:110m land polygons sampled into an offline point cloud.
///
/// Natural Earth data is public domain. See `ATTRIBUTION.md` and
/// `tool/generate_land_data.py` for source and reproducibility details.
class LandData {{
  const LandData._();

  /// Total number of land points on the sphere.
  static const int pointCount = {len(points)};

  /// Flat array of 3D unit-sphere coordinates (x, y, z triples).
  static final Float32List rawCoords = Float32List.fromList(<double>[
{values}
  ]);

  static List<Vector3D>? _cachedPoints;

  /// Returns the precomputed 3D unit vectors for all land points.
  static List<Vector3D> get points => _cachedPoints ??= List<Vector3D>.generate(
        pointCount,
        (index) {{
          final offset = index * 3;
          return Vector3D(
            rawCoords[offset],
            rawCoords[offset + 1],
            rawCoords[offset + 2],
          );
        }},
        growable: false,
      );
}}
"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path)
    parser.add_argument(
        "--output", type=Path, default=Path("lib/src/rendering/land_data.dart")
    )
    args = parser.parse_args()
    points = generate(load_source(args.source))
    if not 2000 <= len(points) <= 4000:
        raise ValueError(f"Unexpected generated point count: {len(points)}")
    args.output.write_text(render(points))
    print(f"Generated {len(points)} land points in {args.output}")


if __name__ == "__main__":
    main()
