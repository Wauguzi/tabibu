/// Geohash encoding for nearest-first search (architecture §6.1).
///
/// Firestore has no geo query, so proximity is a prefix range query on this
/// string: nearby points share a long prefix. Hashes are stored at full
/// precision and a search widens by truncating; characters never stored
/// cannot be recovered.
abstract final class GeohashService {
  /// The published base-32 alphabet. Reordering it invalidates every stored
  /// hash.
  // cspell:disable-next-line
  static const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// About 5 m.
  static const defaultPrecision = 9;

  /// Throws [ArgumentError] on out-of-range input rather than clamping: a
  /// clamped coordinate would place a facility somewhere plausible and wrong.
  static String encode({
    required double lat,
    required double lng,
    int precision = defaultPrecision,
  }) {
    if (precision < 1 || precision > 12) {
      throw ArgumentError.value(
        precision,
        'precision',
        'must be between 1 and 12',
      );
    }
    if (lat.isNaN || lat < -90 || lat > 90) {
      throw ArgumentError.value(lat, 'lat', 'must be between -90 and 90');
    }
    if (lng.isNaN || lng < -180 || lng > 180) {
      throw ArgumentError.value(lng, 'lng', 'must be between -180 and 180');
    }

    var latMin = -90.0;
    var latMax = 90.0;
    var lngMin = -180.0;
    var lngMax = 180.0;

    final hash = StringBuffer();
    var isLng = true;
    var bits = 0;
    var value = 0;

    // `>=` sends a point on a bisector to the upper cell, the convention of
    // the published vectors ((0, 0) encodes to 's0000…'). The server's copy
    // must agree, or a boundary point is silently missed.
    while (hash.length < precision) {
      if (isLng) {
        final mid = (lngMin + lngMax) / 2;
        if (lng >= mid) {
          value = (value << 1) | 1;
          lngMin = mid;
        } else {
          value <<= 1;
          lngMax = mid;
        }
      } else {
        final mid = (latMin + latMax) / 2;
        if (lat >= mid) {
          value = (value << 1) | 1;
          latMin = mid;
        } else {
          value <<= 1;
          latMax = mid;
        }
      }

      isLng = !isLng;
      bits++;

      if (bits == 5) {
        hash.write(_base32[value]);
        bits = 0;
        value = 0;
      }
    }

    return hash.toString();
  }
}
