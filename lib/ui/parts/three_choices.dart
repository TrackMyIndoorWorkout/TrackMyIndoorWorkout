import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class ThreeChoicesBottomSheet extends ConsumerStatefulWidget {
  final String title;
  final bool verticalActions;
  final String firstChoice;
  final String secondChoice;
  final String thirdChoice;

  const ThreeChoicesBottomSheet({
    super.key,
    required this.title,
    required this.verticalActions,
    required this.firstChoice,
    required this.secondChoice,
    required this.thirdChoice,
  });

  @override
  ThreeChoicesBottomSheetState createState() => ThreeChoicesBottomSheetState();
}

class ThreeChoicesBottomSheetState extends ConsumerState<ThreeChoicesBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final themeManager = Get.find<ThemeManager>();
    final themeMode = ref.watch(themeModeProvider);
    final largerTextStyle = Theme.of(context).textTheme.headlineMedium!.apply(
          fontFamily: fontFamily,
          color: themeManager.getProtagonistColor(themeMode),
        );

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
            Text(widget.title, style: largerTextStyle, textAlign: TextAlign.center),
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
