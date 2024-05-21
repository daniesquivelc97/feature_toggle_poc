import 'package:flutter/material.dart';

import 'toggle.dart';

/// Feature requirement types allowing "ANY" or "ALL" operations when evaluating
/// feature gates.
enum FeatureToggleRequirement { any, all }

/// Creates a feature Widget that can be enabled, disabled or partially enabled,
/// described by the provided [featureKeys] and following the [requirement]
class FeatureToggle extends StatefulWidget {
  const FeatureToggle({
    super.key,
    required this.child,
    required this.featureKeys,
    this.requirement = FeatureToggleRequirement.all,
  });

  final List<String> featureKeys;
  final Widget child;
  final FeatureToggleRequirement requirement;

  @override
  FeatureToggleState createState() => FeatureToggleState();
}

class FeatureToggleState extends State<FeatureToggle> {
  FeatureToggleState();

  bool? previousResult;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Toggle.evaluateFeatureGate(
        widget.featureKeys,
        requirement: widget.requirement,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          previousResult = snapshot.data;
          return snapshot.data == true ? widget.child : const SizedBox();
        }

        return previousResult == true ? widget.child : const SizedBox();
      },
    );
  }
}
