import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../preferences/palette_spec.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import '../parts/color_picker.dart';

class ZonePalettePreferencesScreen extends StatefulWidget {
  static String shortTitle = "Palettes";
  final int zoneCount;

  const ZonePalettePreferencesScreen({
    super.key,
    required this.zoneCount,
  });

  @override
  ZonePalettePreferencesScreenState createState() => ZonePalettePreferencesScreenState();
}

class ZonePalettePreferencesScreenState extends State<ZonePalettePreferencesScreen> {
  static String shortTitle = "Palette";
  static String title = "$shortTitle Preferences";
  late final BasePrefService _prefService;
  late final PaletteSpec _paletteSpec;
  late bool _lightOrDark;
  late final List<Color> _fgPalette;
  late final List<Color> _bgPalette;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _textStyle = const TextStyle();
  TextStyle _paletteStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _prefService = Get.find<BasePrefService>();
    _paletteSpec = Get.find<PaletteSpec>();
    _lightOrDark = _themeManager.isDark();
    _fgPalette = _paletteSpec.getPalette(_lightOrDark, true, widget.zoneCount);
    _bgPalette = _paletteSpec.getPalette(_lightOrDark, false, widget.zoneCount);
    _textStyle = Get.textTheme.headlineMedium!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
    _paletteStyle = _textStyle.apply(fontSizeFactor: 2.0);
  }

  Future<void> pickColor(int index, Color color, bool fgOrBg) async {
    final Color? newColor = await Get.bottomSheet(
      SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ColorPickerBottomSheet(color: color),
              ),
            ),
          ],
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
      if (fgOrBg) {
        _fgPalette[index] = color;
      } else {
        _bgPalette[index] = color;
      }
    });
    await _paletteSpec.saveToPreferences(
      _prefService,
      _lightOrDark,
      fgOrBg,
      widget.zoneCount,
      newColor,
      index,
    );
  }

  Widget paletteSelectorActivatorButton(int index, bool fgOrBg) {
    final List<Color> palette = fgOrBg ? _fgPalette : _bgPalette;
    return Container(
      padding: const EdgeInsets.all(5.0),
      margin: const EdgeInsets.all(5.0),
      child: ElevatedButton(
        style: ButtonStyle(backgroundColor: WidgetStateProperty.all(palette[index])),
        onPressed: () async {
          pickColor(index, palette[index], fgOrBg);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(" ", style: _paletteStyle),
          ],
        ),
      ),
    );
  }

  List<Widget> getPaletteRow(bool fgOrBg) {
    List<Widget> items = [
      Center(
        child: Text(fgOrBg ? "FG" : "BG", style: _textStyle),
      ),
    ];

    for (final i in List<int>.generate(widget.zoneCount, (i) => i)) {
      items.add(paletteSelectorActivatorButton(i, fgOrBg));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontal = size.width >= size.height;
    const appBarHeight = 56;
    final columnSizes = [appBarHeight.px, 1.fr, 1.fr];
    final rowSizes = [appBarHeight.px, 1.fr, 1.fr];
    // https://www.geeksforgeeks.org/flutter-set-the-height-of-the-appbar/
    for (final _ in List<int>.generate(widget.zoneCount - 2, (i) => i)) {
      if (horizontal) {
        columnSizes.add(1.fr);
      } else {
        rowSizes.add(1.fr);
      }
    }

    List<Widget> items = [
      Center(
        child: Text("Z#", style: _textStyle),
      )
    ];

    if (horizontal) {
      for (final i in List<int>.generate(widget.zoneCount, (i) => i)) {
        items.add(
          Center(
            child: Text("${i + 1}", style: _textStyle),
          ),
        );
      }

      items.addAll(getPaletteRow(true));
      items.addAll(getPaletteRow(false));
    } else {
      items.addAll([
        Center(
          child: Text("FG", style: _textStyle),
        ),
        Center(
          child: Text("BG", style: _textStyle),
        ),
      ]);

      for (final i in List<int>.generate(widget.zoneCount, (i) => i)) {
        items.addAll([
          Center(
            child: Text("${i + 1}", style: _textStyle),
          ),
          paletteSelectorActivatorButton(i, true),
          paletteSelectorActivatorButton(i, false),
        ]);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Palette Preferences')),
      body: Center(
        child: LayoutGrid(
          columnSizes: columnSizes,
          rowSizes: rowSizes,
          children: items,
        ),
      ),
    );
  }
}
