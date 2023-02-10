import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:tuple/tuple.dart';
import '../../preferences/palette_spec.dart';
import '../../preferences/sport_spec.dart';
import '../../utils/constants.dart';
import '../../utils/sound.dart';
import '../parts/palette_picker.dart';
import 'coloring_by_zone.dart';
import 'measurement_zones.dart';
import 'zone_index_display.dart';
import 'zone_palette.dart';

class ZonesHubScreen extends StatefulWidget {
  static String shortTitle = "Zones";

  const ZonesHubScreen({Key? key}) : super(key: key);

  @override
  ZonesHubScreenState createState() => ZonesHubScreenState();
}

class ZonesHubScreenState extends State<ZonesHubScreen> {
  double _sizeDefault = 10.0;
  TextStyle _textStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headlineSmall!.apply(
      fontFamily: fontFamily,
      color: Colors.white,
    );
    _sizeDefault = _textStyle.fontSize! * 2;
    if (!Get.isRegistered<SoundService>()) {
      Get.put<SoundService>(SoundService(), permanent: true);
    }
    PaletteSpec.getInstance(Get.find<BasePrefService>());
  }

  @override
  Widget build(BuildContext context) {
    final items = SportSpec.sportPrefixes.map((sport) {
      return Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          onPressed: () => Get.to(() => MeasurementZonesPreferencesScreen(sport)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextOneLine(
                sport,
                style: _textStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Icon(Icons.chevron_right, size: _sizeDefault),
            ],
          ),
        ),
      );
    }).toList();

    items.addAll([
      Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          onPressed: () async {
            final Tuple3<bool, bool, int>? paletteSelection = await Get.bottomSheet(
              SafeArea(
                child: Column(
                  children: const [
                    Expanded(
                      child: Center(
                        child: PalettePickerBottomSheet(),
                      ),
                    ),
                  ],
                ),
              ),
              isScrollControlled: true,
              ignoreSafeArea: false,
              enableDrag: false,
            );

            if (paletteSelection == null) {
              return;
            }

            Get.to(() => ZonePalettePreferencesScreen(
                  lightOrDark: paletteSelection.item1,
                  fgOrBg: paletteSelection.item2,
                  size: paletteSelection.item3,
                ));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextOneLine(
                ZonePalettePreferencesScreen.shortTitle,
                style: _textStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Icon(Icons.chevron_right, size: _sizeDefault),
            ],
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          onPressed: () => Get.to(() => const ColoringByZonePreferencesScreen()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextOneLine(
                ColoringByZonePreferencesScreen.shortTitle,
                style: _textStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Icon(Icons.chevron_right, size: _sizeDefault),
            ],
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          onPressed: () => Get.to(() => const ZoneIndexDisplayPreferencesScreen()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextOneLine(
                ZoneIndexDisplayPreferencesScreen.shortTitle,
                style: _textStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Icon(Icons.chevron_right, size: _sizeDefault),
            ],
          ),
        ),
      ),
    ]);

    return Scaffold(
      appBar: AppBar(title: const Text('Zones Preferences')),
      body: ListView(children: items),
    );
  }
}
