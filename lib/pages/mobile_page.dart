import 'package:feature_flags_poc/utils/feature-toggles/toggle.dart';
import 'package:feature_flags_poc/utils/feature_toggles.dart';
import 'package:flutter/material.dart';

class MobilePage extends StatefulWidget {
  const MobilePage({super.key});

  @override
  State<MobilePage> createState() => _MobilePageState();
}

class _MobilePageState extends State<MobilePage> {
  @override
  void initState() {
    initToggle();
    super.initState();
  }

  void initToggle() async {
    await Toggle.init(
      flagDefaults: {
        'FlutterCardKey': true,
        'IonicKey': true,
        'ReactKey': true,
      },
    );
    // await Toggly.init(
    //   flagDefaults: {
    //     'FlutterCardKey': true,
    //     'IonicKey': true,
    //     'ReactKey': true,
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FeatureToggle(
          featureKeys: ['FlutterCardKey'],
          child: CustomCard(text: 'Flutter'),
        ),
        FeatureToggle(
          featureKeys: ['IonicKey'],
          child: CustomCard(text: 'Ionic'),
        ),
        FeatureToggle(
          featureKeys: ['ReactKey'],
          child: CustomCard(text: 'React'),
        ),
        // Feature(
        //   featureKeys: ['FlutterCardKey'],
        //   child: CustomCard(text: 'Flutter'),
        // ),
        // Feature(
        //   featureKeys: ['IonicKey'],
        //   child: CustomCard(text: 'Ionic'),
        // ),
        // Feature(
        //   featureKeys: ['ReactKey'],
        //   child: CustomCard(text: 'React'),
        // ),
      ],
    );
  }
}

class CustomCard extends StatelessWidget {
  const CustomCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            debugPrint('$text tapped.');
          },
          child: SizedBox(
            width: 100,
            height: 100,
            child: Center(child: Text(text)),
          ),
        ),
      ),
    );
  }
}
