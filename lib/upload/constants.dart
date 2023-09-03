import 'package:flutter/material.dart';
import '../utils/theme_manager.dart';

const stravaChoice = "Strava";
const suuntoChoice = "SUUNTO";
const underArmourChoice = "MapMyFitness";
const trainingPeaksChoice = "TrainingPeaks";

const List<String> portalNames = [
  stravaChoice,
  suuntoChoice,
  underArmourChoice,
  trainingPeaksChoice,
];

class PortalChoiceDescriptor {
  final String name;
  final String assetName;
  final Color color;
  final double heightMultiplier;

  PortalChoiceDescriptor(this.name, this.assetName, this.color, this.heightMultiplier);
}

List<PortalChoiceDescriptor> getPortalChoices(bool justAuth, ThemeManager themeManager) {
  return [
    PortalChoiceDescriptor(
      portalNames[0],
      "assets/integration/${justAuth ? "connect_with_strava" : "pwrd_by_strava_2line"}.svg",
      themeManager.getOrangeColor(),
      1.7,
    ),
    PortalChoiceDescriptor(
      portalNames[1],
      "assets/integration/suunto.svg",
      themeManager.getSuuntoRedColor(),
      1.7,
    ),
    PortalChoiceDescriptor(
      portalNames[2],
      "assets/integration/under-armour-2line.svg",
      themeManager.getSuuntoRedColor(),
      1.7,
    ),
    PortalChoiceDescriptor(
      portalNames[3],
      "assets/integration/training-peaks-2line.svg",
      themeManager.getBlueColor(),
      1.7,
    ),
  ];
}
