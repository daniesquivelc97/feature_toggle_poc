import 'dart:async';
import 'dart:convert';

import 'package:feature_flags_poc/utils/feature_toggles.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// Static class providing feature flags support.
/// Allows enabling and disabling of features easily.
class Toggle {
  static Map<String, bool> _flagDefaults = {};
  static final _featureFlagsSubject = BehaviorSubject<Map<String, bool>>();

  static final Toggle _instance = Toggle._internal();

  Toggle._internal();

  factory Toggle() => _instance;

  /// Initialize Toggle either by providing [flagDefaults]
  static Future<ToggleInitResponse> init({
    Map<String, bool>? flagDefaults,
  }) async {
    Toggle._flagDefaults = flagDefaults ?? {};

    if (kDebugMode) {
      print('Toggle.init');
    }

    return await Toggle.refresh();
  }

  /// Refreshes the feature flag values.
  static Future<ToggleInitResponse> refresh() async {
    if (kDebugMode) {
      print('Toggle.refresh');
    }

    Toggle._featureFlagsSubject.add(Toggle._flagDefaults);

    return ToggleInitResponse(
      status: ToggleLoadFeatureFlagsResponse.defaults,
    );
  }

  /// Returns the feature flags default values provided during [init]
  static Map<String, bool> get featureFlagDefaults {
    return Toggle._flagDefaults;
  }

  static bool _evaluateFeatureGate(
    Map<String, bool> flags, {
    required List<String> gate,
    FeatureToggleRequirement requirement = FeatureToggleRequirement.all,
  }) {
    late bool isEnabled;

    if (requirement == FeatureToggleRequirement.any) {
      isEnabled = gate.fold<bool>(false, (isEnabled, featureKey) {
        return isEnabled ||
            (flags.containsKey(featureKey) && flags[featureKey] == true);
      });
    } else {
      isEnabled = gate.fold<bool>(true, (isEnabled, featureKey) {
        return isEnabled &&
            (flags.containsKey(featureKey) && flags[featureKey] == true);
      });
    }

    if (kDebugMode) {
      print('Toggle._evaluateFeatureGate - ${jsonEncode(gate)}');
    }

    return isEnabled;
  }

  /// Evaluates the value of a feature [gate] for the current feature flags
  /// values.
  /// Allows testing for ALL or ANY of the features to be true by using the
  /// [requirement] argument.
  static Future<bool> evaluateFeatureGate(
    List<String> gate, {
    FeatureToggleRequirement requirement = FeatureToggleRequirement.all,
  }) async {
    return Toggle._featureFlagsSubject.whereNotNull().switchMap(
      (flags) async* {
        yield Toggle._evaluateFeatureGate(
          flags,
          gate: gate,
          requirement: requirement,
        );
      },
    ).first;
  }

  /// Closes the feature flags stream.
  static void dispose() {
    Toggle._featureFlagsSubject.close();
  }
}
