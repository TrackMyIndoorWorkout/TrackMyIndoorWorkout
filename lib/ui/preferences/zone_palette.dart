import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/palette_spec.dart';
import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import '../parts/color_picker.dart';

class ZonePalettePreferencesScreen extends ConsumerStatefulWidget {
  static String shortTitle = "Palettes";
  final bool lightOrDark;
  final bool fgOrBg;
  final int size;

  const ZonePalettePreferencesScreen({
    super.key,
    required this.lightOrDark,
    required this.fgOrBg,
    required this.size,
  });

  @override
  ZonePalettePreferencesScreenState createState() => ZonePalettePreferencesScreenState();
}

class ZonePalettePreferencesScreenState extends ConsumerState<ZonePalettePreferencesScreen> {
  static String shortTitle = "Palette";
  static String title = "$shortTitle Preferences";
  late final BasePrefService _prefService;
  late final PaletteSpec _paletteSpec;
  late final List<Color> _palette;
  final ThemeManager _themeManager = Get.find<ThemeManager>();

  @override
  void initState() {
    super.initState();
    _prefService = Get.find<BasePrefService>();
    _paletteSpec = Get.find<PaletteSpec>();
    _palette = _paletteSpec.getPalette(widget.lightOrDark, widget.fgOrBg, widget.size);
  }

  @override
  Widget build(BuildContext context) {
    final sizeDefault = Theme.of(context).textTheme.headlineSmall!.fontSize! * 2;
    final themeMode = ref.watch(themeModeProvider);
    final lightTextStyle = Theme.of(context).textTheme.headlineMedium!.apply(
          fontFamily: fontFamily,
          color: _themeManager.getProtagonistColor(themeMode),
        );
    final darkTextStyle = Theme.of(context).textTheme.headlineMedium!.apply(
          fontFamily: fontFamily,
          color: _themeManager.getAntagonistColor(themeMode),
        );

    List<Widget> items = _palette.mapIndexed((index, color) {
      return Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          style: ButtonStyle(backgroundColor: WidgetStateProperty.all(color)),
          onPressed: () async {
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
              Text("Z${index + 1}", style: lightTextStyle),
              Text("Z${index + 1}", style: darkTextStyle),
              Icon(Icons.chevron_right, size: sizeDefault),
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
