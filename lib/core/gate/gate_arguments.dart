/// What the parent gate should navigate to on success.
///
/// Encoded as a name string so it is safe to pass through go_router state.
enum GateDestination {
  settings,
  privacyPolicy,
  terms
  ;

  static GateDestination fromString(String? raw) {
    return GateDestination.values.firstWhere(
      (d) => d.name == raw,
      orElse: () => GateDestination.settings,
    );
  }
}
