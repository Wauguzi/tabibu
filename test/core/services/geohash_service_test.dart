// cspell:ignore pruydqqvj
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/services/geohash_service.dart';

void main() {
  group('GeohashService.encode', () {
    // Published vectors from independent implementations, so the encoder is
    // checked against the algorithm rather than against itself.
    test('(57.64911, 10.40744) @11 is u4pruydqqvj', () {
      expect(
        GeohashService.encode(lat: 57.64911, lng: 10.40744, precision: 11),
        'u4pruydqqvj',
      );
    });

    test('(52.20, 0.12) @6 is u120fw', () {
      expect(
        GeohashService.encode(lat: 52.20, lng: 0.12, precision: 6),
        'u120fw',
      );
    });

    test('(42.6, -5.6) @5 is ezs42', () {
      expect(
        GeohashService.encode(lat: 42.6, lng: -5.6, precision: 5),
        'ezs42',
      );
    });

    test('encodes the extremes of the coordinate space', () {
      expect(GeohashService.encode(lat: 90, lng: 180), 'zzzzzzzzz');
      expect(GeohashService.encode(lat: -90, lng: -180), '000000000');
    });

    test('a point on both bisectors goes to the upper cell', () {
      expect(GeohashService.encode(lat: 0, lng: 0), 's00000000');
    });

    test('defaults to nine characters', () {
      expect(GeohashService.encode(lat: -1.2921, lng: 36.8219).length, 9);
    });

    test('a shorter hash is a prefix of a longer one for the same point', () {
      final full = GeohashService.encode(
        lat: -1.2921,
        lng: 36.8219,
        precision: 12,
      );
      for (var p = 1; p < 12; p++) {
        expect(
          GeohashService.encode(lat: -1.2921, lng: 36.8219, precision: p),
          full.substring(0, p),
        );
      }
    });

    test('points about 100 m apart in Nairobi share five characters', () {
      final a = GeohashService.encode(lat: -1.2921, lng: 36.8219);
      final b = GeohashService.encode(lat: -1.2930, lng: 36.8219);
      expect(a.substring(0, 5), b.substring(0, 5));
    });

    test('rejects out-of-range coordinates instead of clamping', () {
      expect(() => GeohashService.encode(lat: 91, lng: 0), throwsArgumentError);
      expect(
        () => GeohashService.encode(lat: 0, lng: 181),
        throwsArgumentError,
      );
      expect(
        () => GeohashService.encode(lat: double.nan, lng: 0),
        throwsArgumentError,
      );
    });

    test('rejects an out-of-bounds precision', () {
      expect(
        () => GeohashService.encode(lat: 0, lng: 0, precision: 0),
        throwsArgumentError,
      );
      expect(
        () => GeohashService.encode(lat: 0, lng: 0, precision: 13),
        throwsArgumentError,
      );
    });
  });
}
