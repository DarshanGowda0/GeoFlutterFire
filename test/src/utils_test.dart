import 'package:flutter_test/flutter_test.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geoflutterfire/src/utils/arrays.dart';
import 'package:geoflutterfire/src/utils/math.dart';

void main() {
  test('whereNotNull should remove correct elements', () {
    final param = [
      1,
      2,
      null,
      null,
      3,
      null,
      3,
    ];

    final expected = [1, 2, 3, 3];

    final got = param.whereNotNull();
    expect(expected, got);
  });

  test('distance test', () {
    expect(
      MathUtils.kmDistance(
        Coordinates(90, 0),
        Coordinates(0, 90),
      ),
      closeTo(10001 /*km*/, 2),
    );
  });
}
