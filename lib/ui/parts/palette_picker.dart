import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:pref/pref.dart';
import 'package:tuple/tuple.dart';
import '../../preferences/palette_spec.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class PalettePickerBottomSheet extends StatefulWidget {
  const PalettePickerBottomSheet({Key? key}) : super(key: key);

  @override
  PalettePickerBottomSheetState createState() => PalettePickerBottomSheetState();
}

class PalettePickerBottomSheetState extends State<PalettePickerBottomSheet> {
  bool _lightOrDark = false;
  bool _fgOrBg = false;
  int _size = 5;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _textStyle = const TextStyle();
  TextStyle _largerTextStyle = const TextStyle();
  TextStyle _groupStyle = const TextStyle();
  final _darknessController = GroupButtonController(selectedIndex: 0);
  final _fgBgController = GroupButtonController(selectedIndex: 0);
  final _sizeController = GroupButtonController(selectedIndex: 0);
  GroupButtonOptions? _groupButtonOptions;

  @override
  void initState() {
    super.initState();
    _largerTextStyle = Get.textTheme.headline4!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
    _textStyle = Get.textTheme.headline5!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
    _groupStyle = Get.textTheme.headline5!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getAntagonistColor(),
    );
    _groupButtonOptions = GroupButtonOptions(
      borderRadius: BorderRadius.circular(4),
      selectedTextStyle: _groupStyle,
      selectedColor: _themeManager.getGreenColor(),
      unselectedTextStyle: _groupStyle,
      unselectedColor: _themeManager.getBlueColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Palette type:", style: _largerTextStyle),
            Text("Theme:", style: _textStyle),
            GroupButton(
              controller: _darknessController,
              isRadio: true,
              buttons: const ["Dark", "Light"],
              maxSelected: 1,
              options: _groupButtonOptions!,
              onSelected: (_, i, selected) =>
                  _lightOrDark = (i == 1 && selected || i == 0 && !selected),
            ),
            Text("Fg./Bg.:", style: _textStyle),
            GroupButton(
              controller: _fgBgController,
              isRadio: true,
              buttons: const ["Foregr.", "Backgr."],
              maxSelected: 1,
              options: _groupButtonOptions!,
              onSelected: (_, i, selected) => _fgOrBg = (i == 1 && selected || i == 0 && !selected),
            ),
            Text("Size:", style: _textStyle),
            GroupButton(
              controller: _sizeController,
              isRadio: true,
              buttons: const ["5", "6", "7"],
              maxSelected: 1,
              options: _groupButtonOptions!,
              onSelected: (_, i, selected) {
                if (selected) {
                  _size = i + 5;
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
            _themeManager.getBlueFab(
                Icons.refresh,
                () => {
                      Get.defaultDialog(
                        title: 'Reset all colors to default!',
                        middleText: 'Are you sure?',
                        confirm: TextButton(
                          child: const Text("Yes"),
                          onPressed: () async {
                            final prefService = Get.find<BasePrefService>();
                            for (final lightOrDark in [false, true]) {
                              for (final fgOrBg in [false, true]) {
                                for (final paletteSize in [5, 6, 7]) {
                                  final tag =
                                      PaletteSpec.getPaletteTag(lightOrDark, fgOrBg, paletteSize);
                                  final str = PaletteSpec.getDefaultPaletteString(
                                      lightOrDark, fgOrBg, paletteSize);
                                  await prefService.set<String>(tag, str);
                                }
                              }
                            }
                            Get.close(1);
                          },
                        ),
                        cancel: TextButton(
                          child: const Text("No"),
                          onPressed: () => Get.close(1),
                        ),
                      )
                    }),
            const SizedBox(width: 10, height: 10),
            _themeManager.getGreenFab(Icons.arrow_forward,
                () => Get.back(result: Tuple3<bool, bool, int>(_lightOrDark, _fgOrBg, _size))),
          ],
        ),
      ),
    );
  }
}
