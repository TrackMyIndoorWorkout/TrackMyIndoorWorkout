import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:pref/pref.dart';
import 'package:tuple/tuple.dart';

import '../../preferences/palette_spec.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import 'legend_dialog.dart';

class PalettePickerBottomSheet extends StatefulWidget {
  const PalettePickerBottomSheet({super.key});

  @override
  PalettePickerBottomSheetState createState() => PalettePickerBottomSheetState();
}

class PalettePickerBottomSheetState extends State<PalettePickerBottomSheet> {
  int _zoneCount = 7;
  double _mediaHeight = 0;
  double _mediaWidth = 0;
  bool _landscape = false;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _textStyle = const TextStyle();
  TextStyle _groupStyle = const TextStyle();
  final _zoneCountController = GroupButtonController(selectedIndex: 0);
  late final GroupButtonOptions _landscapeGroupButtonOptions;
  late final GroupButtonOptions _portraitGroupButtonOptions;

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headlineSmall!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
    _groupStyle = Get.textTheme.headlineSmall!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getAntagonistColor(),
    );
    _landscapeGroupButtonOptions = GroupButtonOptions(
      borderRadius: BorderRadius.circular(4),
      selectedTextStyle: _groupStyle,
      selectedColor: _themeManager.getGreenColor(),
      unselectedTextStyle: _groupStyle,
      unselectedColor: _themeManager.getBlueColor(),
      direction: Axis.vertical,
    );
    _portraitGroupButtonOptions = GroupButtonOptions(
      borderRadius: BorderRadius.circular(4),
      selectedTextStyle: _groupStyle,
      selectedColor: _themeManager.getGreenColor(),
      unselectedTextStyle: _groupStyle,
      unselectedColor: _themeManager.getBlueColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = Get.mediaQuery.size;
    if (size.width != _mediaWidth || size.height != _mediaHeight) {
      _mediaWidth = size.width;
      _mediaHeight = size.height;
      _landscape = _mediaWidth > _mediaHeight;
    }

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("Zone Count:", style: _textStyle),
            GroupButton(
              controller: _zoneCountController,
              isRadio: true,
              buttons: const ["5", "6", "7"],
              maxSelected: 1,
              options: _landscape ? _landscapeGroupButtonOptions : _portraitGroupButtonOptions,
              onSelected: (_, i, selected) {
                if (selected) {
                  _zoneCount = i + 5;
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _themeManager.getBlueFab(Icons.arrow_back, () => Get.back()),
            const SizedBox(width: 30, height: 10),
            _themeManager.getBlueFab(Icons.info_rounded, () {
              legendDialog([
                const Tuple2<IconData, String>(Icons.arrow_back, "Navigate back"),
                const Tuple2<IconData, String>(Icons.info_rounded, "Help Legend"),
                const Tuple2<IconData, String>(Icons.format_color_reset, "Reset all to default"),
                const Tuple2<IconData, String>(Icons.arrow_forward, "Configure palette"),
              ]);
            }),
            const SizedBox(width: 30, height: 10),
            _themeManager.getBlueFab(
              Icons.format_color_reset,
              () => Get.defaultDialog(
                title: 'Reset all colors to default!',
                middleText: 'Are you sure?',
                confirm: TextButton(
                  child: const Text("Yes"),
                  onPressed: () async {
                    final prefService = Get.find<BasePrefService>();
                    for (final lightOrDark in [false, true]) {
                      for (final fgOrBg in [false, true]) {
                        for (final paletteSize in [5, 6, 7]) {
                          final tag = PaletteSpec.getPaletteTag(lightOrDark, fgOrBg, paletteSize);
                          final str = PaletteSpec.getDefaultPaletteString(
                            lightOrDark,
                            fgOrBg,
                            paletteSize,
                          );
                          await prefService.set<String>(tag, str);
                        }
                      }
                    }
                    Get.close(1);
                  },
                ),
                cancel: TextButton(child: const Text("No"), onPressed: () => Get.close(1)),
              ),
            ),
            const SizedBox(width: 30, height: 10),
            _themeManager.getGreenFab(Icons.arrow_forward, () => Get.back(result: _zoneCount)),
          ],
        ),
      ),
    );
  }
}
