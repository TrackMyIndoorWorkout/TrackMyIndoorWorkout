import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/theme_manager.dart';

const stravaChoice = "Strava";
const suuntoChoice = "SUUNTO";
const underArmourChoice = "MapMyFitness";
const trainingPeaksChoice = "TrainingPeaks";
const anyChoice = "Any";

const List<String> portalNames = [
  stravaChoice,
  suuntoChoice,
  underArmourChoice,
  trainingPeaksChoice,
];

class PortalChoiceDescriptor {
  final String name;
  final String iconName;
  final String logoName;
  final Color color;
  final double heightMultiplier;

  PortalChoiceDescriptor(
      this.name, this.iconName, this.logoName, this.color, this.heightMultiplier);

  Widget getSvg(bool icon, double baseHeight) {
    return SvgPicture.asset(
      icon ? iconName : logoName,
      colorFilter: const ColorFilter.mode(Colors.transparent, BlendMode.srcATop),
      height: baseHeight * heightMultiplier,
      semanticsLabel: '$name Logo',
    );
  }
}

List<PortalChoiceDescriptor> getPortalChoices(bool justAuth, ThemeManager themeManager) {
  return [
    PortalChoiceDescriptor(
      portalNames[0],
      "assets/integration/strava-logo.svg",
      "assets/integration/${justAuth ? "connect_with_strava" : "pwrd_by_strava_2line"}.svg",
      themeManager.getOrangeColor(),
      1.7,
    ),
    PortalChoiceDescriptor(
      portalNames[1],
      "assets/integration/suunto-logo.svg",
      "assets/integration/suunto.svg",
      themeManager.getSuuntoRedColor(),
      1.7,
    ),
    PortalChoiceDescriptor(
      portalNames[2],
      "assets/integration/under-armour-logo.svg",
      "assets/integration/under-armour-2line.svg",
      themeManager.getSuuntoRedColor(),
      1.7,
    ),
    PortalChoiceDescriptor(
      portalNames[3],
      "assets/integration/training-peaks-logo.svg",
      "assets/integration/training-peaks-2line.svg",
      themeManager.getBlueColor(),
      1.7,
    ),
  ];
}
