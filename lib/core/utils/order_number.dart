/// The server's order number (`mintOrderNumber`): ODR, the doctor's two
/// initials, the patient's two or three, the Nairobi date as DDMMYYYY and
/// the day's sequence, e.g. ODR-JK-AW-02112026-001.
final RegExp _orderNumber = RegExp(r'^ODR-[A-Z]{2}-[A-Z]{2,3}-\d{8}-\d{3}$');

/// Whether [query] is a whole order number, in any case.
bool isOrderNumber(String query) =>
    _orderNumber.hasMatch(query.trim().toUpperCase());

/// Whether [query] is an attempt at an order number that isn't one yet: it
/// starts with ODR but doesn't match. Search shows the format hint for these
/// rather than "no results".
bool looksLikeOrderNumber(String query) {
  final upper = query.trim().toUpperCase();
  return upper.startsWith('ODR') && !_orderNumber.hasMatch(upper);
}
