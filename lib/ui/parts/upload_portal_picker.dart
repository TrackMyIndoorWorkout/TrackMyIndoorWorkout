import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:track_my_indoor_exercise/upload/upload_service.dart';
import '../../utils/theme_manager.dart';

class PortalChoiceDescriptor {
  final String name;
  final String assetName;
  final Color color;
  final double heightMultiplier;

  PortalChoiceDescriptor(this.name, this.assetName, this.color, this.heightMultiplier);
}

class UploadPortalPickerBottomSheet extends StatefulWidget {
  const UploadPortalPickerBottomSheet({Key? key}) : super(key: key);

  @override
  UploadPortalPickerBottomSheetState createState() => UploadPortalPickerBottomSheetState();
}

class UploadPortalPickerBottomSheetState extends State<UploadPortalPickerBottomSheet> {
  int _portalIndex = 0;
  final List<String> _portalNames = [
    "Strava",
    "SUUNTO",
    "MapMyFitness",
    "TrainingPeaks",
  ];
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  List<PortalChoiceDescriptor> _portalChoices = [];
  TextStyle _largerTextStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _portalChoices = [
      PortalChoiceDescriptor(
          _portalNames[0], "assets/strava.svg", _themeManager.getOrangeColor(), 1.5),
      PortalChoiceDescriptor(
          _portalNames[1], "assets/suunto.svg", _themeManager.getSuuntoRedColor(), 2.0),
      PortalChoiceDescriptor(
          _portalNames[2], "assets/under-armour-2line.svg", _themeManager.getSuuntoRedColor(), 2.0),
      PortalChoiceDescriptor(
          _portalNames[3], "assets/training-peaks-2line.svg", _themeManager.getBlueColor(), 2.0),
    ];
    _portalIndex = max(0, _portalNames.indexOf("Strava"));
    _largerTextStyle = Get.textTheme.headline4!;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> choiceRows = [];
    choiceRows.addAll(
      _portalChoices.asMap().entries.map(
            (e) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 2,
                      child: Radio(
                        value: e.key,
                        groupValue: _portalIndex,
                        onChanged: (value) {
                          setState(() {
                            _portalIndex = value as int;
                          });
                        },
                      ),
                    ),
                    e.value.assetName.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _portalIndex = e.key;
                              });
                            },
                            child: SvgPicture.asset(
                              e.value.assetName,
                              color: e.value.color,
                              height: _largerTextStyle.fontSize! * e.value.heightMultiplier,
                              semanticsLabel: '${e.value.name} Logo',
                            ),
                          )
                        : Container(),
                  ],
                ),
                Divider(height: _largerTextStyle.fontSize! / 2),
              ],
            ),
          ),
    );

    if (kDebugMode) {
      choiceRows.add(const Divider());
      choiceRows.add(
        ElevatedButton.icon(
            icon: const Icon(Icons.exit_to_app),
            label: const Text("Deauthorize"),
            onPressed: () async {
              UploadService uploadService = UploadService.getInstance(_portalNames[_portalIndex]);

              final returnCode = await uploadService.deAuthorize();
              Get.snackbar("Deauthorization", "Return code: $returnCode");
            }),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: choiceRows,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getGreenFab(
          Icons.check, false, false, "", 0, () => Get.back(result: _portalNames[_portalIndex])),
    );
  }
}
