import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/palette_spec.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import '../parts/color_picker.dart';

class ZonePalettePreferencesScreen extends StatefulWidget {
  static String shortTitle = "Palettes";
  final bool lightOrDark;
  final bool fgOrBg;
  final int size;

  const ZonePalettePreferencesScreen({
    Key? key,
    required this.lightOrDark,
    required this.fgOrBg,
    required this.size,
  }) : super(key: key);

  @override
  ZonePalettePreferencesScreenState createState() => ZonePalettePreferencesScreenState();
}

class ZonePalettePreferencesScreenState extends State<ZonePalettePreferencesScreen> {
  static String shortTitle = "Palette";
  static String title = "$shortTitle Preferences";
  late final BasePrefService _prefService;
  late final PaletteSpec _paletteSpec;
  late final List<Color> _palette;
  double _sizeDefault = 10.0;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _lightTextStyle = const TextStyle();
  TextStyle _darkTextStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _prefService = Get.find<BasePrefService>();
    _paletteSpec = Get.find<PaletteSpec>();
    _palette = _paletteSpec.getPalette(widget.lightOrDark, widget.fgOrBg, widget.size);
    _sizeDefault = Get.textTheme.headline5!.fontSize! * 2;
    _lightTextStyle = Get.textTheme.headline4!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
    _darkTextStyle = Get.textTheme.headline4!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getAntagonistColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = _palette.mapIndexed((index, color) {
      debugPrint("$index $color");
      return Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(color)),
          onPressed: () async {
            final Color? newColor = await Get.bottomSheet(
              SafeArea(
                child: Expanded(
                  child: Center(
                    child: ColorPickerBottomSheet(color: color),
                  ),
                ),
              ),
              isScrollControlled: true,
              ignoreSafeArea: false,
              enableDrag: false,
            );

            if (newColor == null) {
              return;
            }

            setState(() {
              _palette[index] = color;
            });
            await _paletteSpec.saveToPreferences(
              _prefService,
              widget.lightOrDark,
              widget.fgOrBg,
              widget.size,
              newColor,
              index,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Z${index + 1}", style: _lightTextStyle),
              Text("Z${index + 1}", style: _darkTextStyle),
              Icon(Icons.chevron_right, size: _sizeDefault),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Palette Preferences')),
      body: ListView(children: items),
    );
  }
}
