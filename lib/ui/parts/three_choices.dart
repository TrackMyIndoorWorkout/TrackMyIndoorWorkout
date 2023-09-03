import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class ThreeChoicesBottomSheet extends StatefulWidget {
  final String title;
  final bool verticalActions;
  final String firstChoice;
  final String secondChoice;
  final String thirdChoice;

  const ThreeChoicesBottomSheet({
    Key? key,
    required this.title,
    required this.verticalActions,
    required this.firstChoice,
    required this.secondChoice,
    required this.thirdChoice,
  }) : super(key: key);

  @override
  ThreeChoicesBottomSheetState createState() => ThreeChoicesBottomSheetState();
}

class ThreeChoicesBottomSheetState extends State<ThreeChoicesBottomSheet> {
  TextStyle _largerTextStyle = const TextStyle();
  final _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _largerTextStyle = Get.textTheme.headlineMedium!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      ElevatedButton(
        onPressed: () => Get.back(result: 0),
        child: Text(
          widget.firstChoice,
          textScaler: const TextScaler.linear(2.0),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(width: 10, height: 10),
      ElevatedButton(
        onPressed: () => Get.back(result: 1),
        child: Text(
          widget.secondChoice,
          textScaler: const TextScaler.linear(2.0),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(width: 10, height: 10),
      ElevatedButton(
        onPressed: () => Get.back(result: 2),
        child: Text(
          widget.thirdChoice,
          textScaler: const TextScaler.linear(2.0),
          textAlign: TextAlign.center,
        ),
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: _largerTextStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.all(10.0),
        child: widget.verticalActions
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: actions,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: actions,
              ),
      ),
    );
  }
}
