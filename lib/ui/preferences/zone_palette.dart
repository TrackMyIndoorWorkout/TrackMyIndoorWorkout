import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/palette_spec.dart';
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

  @override
  void initState() {
    super.initState();

    _prefService = Get.find<BasePrefService>();
    _paletteSpec = Get.find<PaletteSpec>();
    _palette = _paletteSpec.getPalette(widget.lightOrDark, widget.fgOrBg, widget.size);
    _sizeDefault = Get.textTheme.headline5!.fontSize! * 2;
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
              ColorPickerBottomSheet(color: color),
              enableDrag: false,
            );

            if (newColor == null) {
              return;
            }

            setState(() {
              _palette[index] = color;
            });
            _paletteSpec.saveToPreferences(
              _prefService,
              widget.lightOrDark,
              widget.fgOrBg,
              widget.size,
              newColor,
              index,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.chevron_right, size: _sizeDefault),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Palette Preferences')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items,
        ),
      ),
    );
  }
}
