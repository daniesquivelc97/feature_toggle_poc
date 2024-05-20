/// Possible feature flags values loading responses.
enum ToggleLoadFeatureFlagsResponse {
  /// Fetched from the Toggly.io Client API.
  fetched,

  /// Loaded from the cache.
  cached,

  /// Used the feature flag defaults provided during Toggle.init.
  defaults,

  /// Something, somewhere, went wrong.
  error,
}

/// Toggly initialization response model.
class ToggleInitResponse {
  final ToggleLoadFeatureFlagsResponse status;

  ToggleInitResponse({
    required this.status,
  });
}
