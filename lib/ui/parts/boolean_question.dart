import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class BooleanQuestionBottomSheet extends StatefulWidget {
  final String title;
  final String content;

  const BooleanQuestionBottomSheet({super.key, required this.title, required this.content});

  @override
  BooleanQuestionBottomSheetState createState() => BooleanQuestionBottomSheetState();
}

class BooleanQuestionBottomSheetState extends State<BooleanQuestionBottomSheet> {
  TextStyle _largerTextStyle = const TextStyle();
  TextStyle _textStyle = const TextStyle();
  final _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _largerTextStyle = Get.textTheme.headlineMedium!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
    _textStyle = Get.textTheme.headlineSmall!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: _largerTextStyle, textAlign: TextAlign.center),
            const Divider(),
            Text(widget.content, style: _textStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Get.back(result: false),
              child: const Text(
                "No",
                textScaler: TextScaler.linear(2.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10, height: 10),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                "Yes",
                textScaler: TextScaler.linear(2.0),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
