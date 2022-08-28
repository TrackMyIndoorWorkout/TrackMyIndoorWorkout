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

class ThreeChoicesBottomSheetState extends ConsumerState<ThreeChoicesBottomSheet> {
  TextStyle _largerTextStyle = const TextStyle();
  final _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    final themeMode = ref.watch(themeModeProvider);
    _largerTextStyle = Get.textTheme.headline4!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(themeMode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      ElevatedButton(
        onPressed: () => Get.back(result: 0),
        child: Text(widget.firstChoice, textScaleFactor: 2.0, textAlign: TextAlign.center),
      ),
      const SizedBox(width: 10, height: 10),
      ElevatedButton(
        onPressed: () => Get.back(result: 1),
        child: Text(widget.secondChoice, textScaleFactor: 2.0, textAlign: TextAlign.center),
      ),
      const SizedBox(width: 10, height: 10),
      ElevatedButton(
        onPressed: () => Get.back(result: 2),
        child: Text(widget.thirdChoice, textScaleFactor: 2.0, textAlign: TextAlign.center),
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
