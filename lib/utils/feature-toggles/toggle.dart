import 'dart:async';
import 'dart:convert';

import 'package:feature_flags_poc/utils/feature_toggles.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// Static class providing feature flags support.
///
/// Allows enabling and disabling of features easily. Can be used with or without Toggly.io.
class Toggle {
  // static const Uuid _uuid = Uuid();
  // static late String? _appKey;
  // static String _environment = 'Production';
  // static late String _identity;
  // static late ToggleConfig _config;
  static Map<String, bool> _flagDefaults = {};
  // static final _http = HttpService.getInstance.http;
  // static final _storage = SecureStorageService.getInstance;
  // static final _sync = SyncService.getInstance;
  static final _featureFlagsSubject = BehaviorSubject<Map<String, bool>>();

  static final Toggle _instance = Toggle._internal();

  Toggle._internal();

  factory Toggle() => _instance;

  /// Initialize Toggly either by providing [flagDefaults] (to allow usage
  /// without Toggly.io) or by providing your [appKey] and [environment] from
  /// your Toggly.io application.
  ///
  /// You can also set various configuration settings through [config], such as
  /// baseUri, connectTimeout or featureFlagsRefreshInterval
  static Future<ToggleInitResponse> init({
    String? appKey,
    String? environment,
    // String? identity,
    ToggleConfig config = const ToggleConfig(),
    Map<String, bool>? flagDefaults,
  }) async {
    // Toggle._appKey = appKey;
    // Toggle._environment = environment ?? 'Production';
    // Toggle._identity = identity ?? Toggle._uuid.v4();
    // Toggle._config = config;
    Toggle._flagDefaults = flagDefaults ?? {};

    if (kDebugMode) {
      print('Toggly.init');
    }

    // Toggle.startTimers();

    return await Toggle.refresh();
  }

  /// Refreshes the feature flag values.
  ///
  /// In case there is no API key provided, only the flag defaults shall be
  /// used.
  ///
  /// Otherwise fetch feature flags values from the Toggly Client API. If
  /// that fails it loads feature flags from cache and defaults to the
  /// previously provided [flagDefaults] during [init]
  static Future<ToggleInitResponse> refresh() async {
    if (kDebugMode) {
      print('Toggly.refresh');
    }

    // In case there is no API key provided, only the flag defaults shall be used
    // if (Toggle._appKey == null) {
    Toggle._featureFlagsSubject.add(Toggle._flagDefaults);

    return ToggleInitResponse(
      status: ToggleLoadFeatureFlagsResponse.defaults,
    );
    // }

    // try {
    //   // Try to fetch flags from the API
    //   // await Toggle.fetchFeatureFlags();

    //   return ToggleInitResponse(
    //     status: ToggleLoadFeatureFlagsResponse.fetched,
    //   );
    // } catch (_) {
    //   // Try to load flags from Cache
    //   // var flags = await Toggle.cachedFeatureFlags;
    //   var status = ToggleLoadFeatureFlagsResponse.cached;

    //   // if (flags == null) {
    //   //   // Otherwise use provided default flags
    //   //   flags = Toggle._flagDefaults;
    //   //   status = ToggleLoadFeatureFlagsResponse.defaults;

    //   //   if (kDebugMode) {
    //   //     print('Toggly.usedFlagDefaults - ${jsonEncode(flags)}');
    //   //   }
    //   // } else {
    //   //   if (kDebugMode) {
    //   //     print('Toggly.loadedFromCache - ${jsonEncode(flags)}');
    //   //   }
    //   // }

    //   // Toggle._featureFlagsSubject.add(flags);

    //   return ToggleInitResponse(
    //     status: status,
    //   );
    // }
  }

  /// Sets an unique identifier to the current session. Useful in case of custom
  /// feature rollouts.
  // static Future<ToggleInitResponse> setIdentity(String? identity) async {
  //   Toggle._identity = identity ?? Toggle._uuid.v4();
  //   return await Toggle.refresh();
  // }

  /// Returns a [Future] with the current feature flags values.
  // static Future<Map<String, bool>> get featureFlags async {
  //   try {
  //     if (Toggle._appKey == null) {
  //       throw ToggleMissingAppKeyException();
  //     }

  //     // return await Toggle.cachedFeatureFlags ?? await fetchFeatureFlags();
  //   } catch (_) {
  //     return Toggle._flagDefaults;
  //   }
  // }

  /// Returns a [Future] with the cached feature flags values.
  // static Future<Map<String, bool>?> get cachedFeatureFlags async {
  //   try {
  //     String? cache = await _storage.get(
  //         key: SecureStorageKeys.featureFlagsCache.toString());

  //     ToggleFeatureFlagsCache flagsCache = ToggleFeatureFlagsCache.fromJson(
  //       jsonDecode(cache!),
  //     );

  //     return flagsCache.identity == Toggle._identity ? flagsCache.flags : null;
  //   } catch (_) {
  //     return null;
  //   }
  // }

  /// Stores the provided [featureFlags] into cache.
  // static void cacheFeatureFlags({
  //   required Map<String, bool> featureFlags,
  // }) async {
  //   await _storage.set(
  //     key: SecureStorageKeys.featureFlagsCache.toString(),
  //     value: jsonEncode(ToggleFeatureFlagsCache(
  //       identity: Toggle._identity,
  //       flags: featureFlags,
  //     )),
  //   );
  // }

  /// Clears the feature flags cache.
  // static void clearFeatureFlagsCache() async {
  //   await _storage.delete(
  //     key: SecureStorageKeys.featureFlagsCache.toString(),
  //   );
  // }

  /// Returns the feature flags default values provided during [init]
  static Map<String, bool> get featureFlagDefaults {
    return Toggle._flagDefaults;
  }

  /// Retrieves feature flags values from the e.io Client API.
  // static Future<Map<String, bool>> fetchFeatureFlags() async {
  //   try {
  // final response = await _http.get(
  //   '${Toggle._config.baseURI}/${Toggle._appKey}-${Toggle._environment}/defs?u=${Toggle._identity}',
  //   queryParameters: {},
  // );

  //     Map<String, bool> flags = Map<String, bool>.from(response.data);

  //     // Cache flags on successful response
  //     Toggle.cacheFeatureFlags(featureFlags: flags);

  //     Toggle._featureFlagsSubject.add(flags);

  //     if (kDebugMode) {
  //       print('Toggle.fetchFeatureFlags - ${jsonEncode(flags)}');
  //     }

  //     return flags;
  //   } catch (_) {
  //     throw Exception('Failed to fetch feature flags from the API.');
  //   }
  // }

  static bool _evaluateFeatureGate(
    Map<String, bool> flags, {
    required List<String> gate,
    FeatureToggleRequirement requirement = FeatureToggleRequirement.all,
    bool negate = false,
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
      print('Toggly._evaluateFeatureGate - ${jsonEncode(gate)}');
    }

    return negate ? !isEnabled : isEnabled;
  }

  /// Evaluates the value of a feature [gate] for the current feature flags
  /// values.
  ///
  /// Allows testing for ALL or ANY of the features to be true by using the
  /// [requirement] argument.
  ///
  /// Allows negation through the [negate] argument.
  static Future<bool> evaluateFeatureGate(
    List<String> gate, {
    FeatureToggleRequirement requirement = FeatureToggleRequirement.all,
    bool negate = false,
  }) async {
    return Toggle._featureFlagsSubject.whereNotNull().switchMap(
      (flags) async* {
        yield Toggle._evaluateFeatureGate(flags,
            gate: gate, requirement: requirement, negate: negate);
      },
    ).first;
  }

  /// Cancels registered timers and closes the feature flags stream.
  static void dispose() {
    // cancelTimers();
    Toggle._featureFlagsSubject.close();
  }

  /// Starts a [Timer] to periodically retrieve the feature flags values from
  /// the Toggly.io Client API.
  ///
  /// It only registers the timer if an [appKey] is provided during the [init]
  /// call.
  // static void startTimers() {
  //   cancelTimers();

  //   // Automatic refresh only runs if there is an API key provided
  //   if (Toggle._appKey != null) {
  //     Toggle._sync.refreshFeatureFlagsTimer = Timer.periodic(
  //       Duration(milliseconds: Toggle._config.featureFlagsRefreshInterval),
  //       (timer) async {
  //         if (kDebugMode) {
  //           print(
  //               'Toggle.syncFeatureFlags - every ${Toggle._config.featureFlagsRefreshInterval / 1000}s');
  //         }

  //         await Toggle.refresh();
  //       },
  //     );
  //   }
  // }

  /// Cancels the registered timers.
  // static void cancelTimers() {
  //   Toggle._sync.refreshFeatureFlagsTimer?.cancel();
  // }
}
