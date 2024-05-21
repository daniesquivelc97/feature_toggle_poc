enum ToggleLoadFeatureFlagsResponse {
  defaults,
  error,
}

/// Toggle initialization response model.
class ToggleInitResponse {
  final ToggleLoadFeatureFlagsResponse status;

  ToggleInitResponse({
    required this.status,
  });
}
