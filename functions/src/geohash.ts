/**
 * The server's copy of `lib/core/services/geohash_service.dart`. The server recomputes every
 * geohash it stores, so this copy decides where a record lands; it is pinned to the app's own
 * vectors in `geohash.test.ts`.
 */

// cspell:disable-next-line
const BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/** About 5 m. A search widens by truncating. */
export const GEOHASH_PRECISION = 9;

export function encodeGeohash(lat: number, lng: number, precision = GEOHASH_PRECISION): string {
  if (!Number.isInteger(precision) || precision < 1 || precision > 12) {
    throw new RangeError(`precision must be between 1 and 12, got ${precision}`);
  }
  if (Number.isNaN(lat) || lat < -90 || lat > 90) {
    throw new RangeError(`lat must be between -90 and 90, got ${lat}`);
  }
  if (Number.isNaN(lng) || lng < -180 || lng > 180) {
    throw new RangeError(`lng must be between -180 and 180, got ${lng}`);
  }

  let [latMin, latMax, lngMin, lngMax] = [-90, 90, -180, 180];
  let hash = '';
  let isLng = true;
  let bits = 0;
  let value = 0;

  while (hash.length < precision) {
    // `>=` sends a point on a bisector to the upper cell, as the app does.
    if (isLng) {
      const mid = (lngMin + lngMax) / 2;
      if (lng >= mid) {
        value = (value << 1) | 1;
        lngMin = mid;
      } else {
        value <<= 1;
        lngMax = mid;
      }
    } else {
      const mid = (latMin + latMax) / 2;
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
    if (bits === 5) {
      hash += BASE32[value];
      bits = 0;
      value = 0;
    }
  }
  return hash;
}
