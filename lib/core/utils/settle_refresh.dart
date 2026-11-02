/// Completes once [states] emits something [isLoading] rejects, so a
/// `RefreshIndicator` keeps its arc until the data arrives. Every failure
/// (no emit, a timeout, the stream closing as the screen pops) retracts the
/// arc instead of stranding it.
Future<void> settleRefresh<S>(
  Stream<S> states,
  bool Function(S state) isLoading, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    await states.firstWhere((s) => !isLoading(s)).timeout(timeout);
  } on Object {
    return;
  }
}
