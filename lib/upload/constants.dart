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

const List<String> portalLogos = [
  "strava.svg",
  "suunto.svg",
  "under-armour-2line.svg",
  "training-peaks-2line.svg",
];

class PortalChoiceDescriptor {
  final String name;
  final String assetName;
  final Color color;
  final double heightMultiplier;

  PortalChoiceDescriptor(this.name, this.assetName, this.color, this.heightMultiplier);
}

List<PortalChoiceDescriptor> getPortalChoices(ThemeManager themeManager, ThemeMode themeMode) {
  return [
    PortalChoiceDescriptor(
      portalNames[0],
      "assets/${portalLogos[0]}",
      themeManager.getOrangeColor(themeMode),
      1.0,
    ),
    PortalChoiceDescriptor(
      portalNames[1],
      "assets/${portalLogos[1]}",
      themeManager.getSuuntoRedColor(themeMode),
      1.5,
    ),
    PortalChoiceDescriptor(
      portalNames[2],
      "assets/${portalLogos[2]}",
      themeManager.getSuuntoRedColor(themeMode),
      1.5,
    ),
    PortalChoiceDescriptor(
      portalNames[3],
      "assets/${portalLogos[3]}",
      themeManager.getBlueColor(themeMode),
      1.5,
    ),
  ];
}
