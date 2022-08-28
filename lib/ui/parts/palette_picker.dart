import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:pref/pref.dart';
import 'package:tuple/tuple.dart';
import '../../preferences/palette_spec.dart';
import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class PalettePickerBottomSheet extends ConsumerStatefulWidget {
  const PalettePickerBottomSheet({Key? key}) : super(key: key);

  @override
  PalettePickerBottomSheetState createState() => PalettePickerBottomSheetState();
}

class PalettePickerBottomSheetState extends ConsumerState<PalettePickerBottomSheet> {
  bool _lightOrDark = false;
  bool _fgOrBg = false;
  int _size = 5;
  double _mediaHeight = 0;
  double _mediaWidth = 0;
  bool _landscape = false;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _textStyle = const TextStyle();
  TextStyle _largerTextStyle = const TextStyle();
  TextStyle _groupStyle = const TextStyle();
  final _darknessController = GroupButtonController(selectedIndex: 0);
  final _fgBgController = GroupButtonController(selectedIndex: 0);
  final _sizeController = GroupButtonController(selectedIndex: 0);
  GroupButtonOptions? _landscapeGroupButtonOptions;
  GroupButtonOptions? _portraitGroupButtonOptions;

  @override
  void initState() {
    super.initState();
    final themeMode = ref.watch(themeModeProvider);
    _largerTextStyle = Get.textTheme.headline4!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(themeMode),
    );
    _textStyle = Get.textTheme.headline5!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(themeMode),
    );
    _groupStyle = Get.textTheme.headline5!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getAntagonistColor(themeMode),
    );
    _landscapeGroupButtonOptions = GroupButtonOptions(
      borderRadius: BorderRadius.circular(4),
      selectedTextStyle: _groupStyle,
      selectedColor: _themeManager.getGreenColor(themeMode),
      unselectedTextStyle: _groupStyle,
      unselectedColor: _themeManager.getBlueColor(themeMode),
      direction: Axis.vertical,
    );
    _portraitGroupButtonOptions = GroupButtonOptions(
      borderRadius: BorderRadius.circular(4),
      selectedTextStyle: _groupStyle,
      selectedColor: _themeManager.getGreenColor(themeMode),
      unselectedTextStyle: _groupStyle,
      unselectedColor: _themeManager.getBlueColor(themeMode),
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
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: _landscape
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text("Palette", style: _largerTextStyle),
                      Text("type:", style: _largerTextStyle),
                    ],
                  ),
                  const VerticalDivider(),
                  Column(
                    children: [
                      Text("Theme:", style: _textStyle),
                      GroupButton(
                        controller: _darknessController,
                        isRadio: true,
                        buttons: const ["Dark", "Light"],
                        maxSelected: 1,
                        options: _landscapeGroupButtonOptions!,
                        onSelected: (_, i, selected) =>
                            _lightOrDark = (i == 1 && selected || i == 0 && !selected),
                      ),
                    ],
                  ),
                  const VerticalDivider(),
                  Column(
                    children: [
                      Text("Fg./Bg.:", style: _textStyle),
                      GroupButton(
                        controller: _fgBgController,
                        isRadio: true,
                        buttons: const ["Foregr.", "Backgr."],
                        maxSelected: 1,
                        options: _landscapeGroupButtonOptions!,
                        onSelected: (_, i, selected) =>
                            _fgOrBg = (i == 1 && selected || i == 0 && !selected),
                      ),
                    ],
                  ),
                  const VerticalDivider(),
                  Column(
                    children: [
                      Text("Size:", style: _textStyle),
                      GroupButton(
                        controller: _sizeController,
                        isRadio: true,
                        buttons: const ["5", "6", "7"],
                        maxSelected: 1,
                        options: _landscapeGroupButtonOptions!,
                        onSelected: (_, i, selected) {
                          if (selected) {
                            _size = i + 5;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Center(
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
                    options: _portraitGroupButtonOptions!,
                    onSelected: (_, i, selected) =>
                        _lightOrDark = (i == 1 && selected || i == 0 && !selected),
                  ),
                  Text("Fg./Bg.:", style: _textStyle),
                  GroupButton(
                    controller: _fgBgController,
                    isRadio: true,
                    buttons: const ["Foregr.", "Backgr."],
                    maxSelected: 1,
                    options: _portraitGroupButtonOptions!,
                    onSelected: (_, i, selected) =>
                        _fgOrBg = (i == 1 && selected || i == 0 && !selected),
                  ),
                  Text("Size:", style: _textStyle),
                  GroupButton(
                    controller: _sizeController,
                    isRadio: true,
                    buttons: const ["5", "6", "7"],
                    maxSelected: 1,
                    options: _portraitGroupButtonOptions!,
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
                themeMode,
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
            _themeManager.getGreenFab(
              Icons.arrow_forward,
              themeMode,
              () => Get.back(result: Tuple3<bool, bool, int>(_lightOrDark, _fgOrBg, _size)),
            ),
          ],
        ),
      ),
    );
  }
}
