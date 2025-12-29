import 'package:flutter/material.dart';
import '../../utils/theme_manager.dart';

enum MeasurementRowLayout {
  standard, // Icon | Spacer | Value | Unit
  split, // Value | Icon+Unit | Statistic
  divider, // Divider
}

class MeasurementRow extends StatelessWidget {
  const MeasurementRow({
    super.key,
    required this.themeManager,
    required this.layout,
    required this.icon,
    this.iconColor,
    required this.iconSize,
    required this.value,
    required this.unit,
    this.statistic = "",
    required this.measurementStyle,
    required this.unitStyle,
    required this.fullUnitStyle,
    required this.expandable,
    this.simplerUi = false,
  });

  final ThemeManager themeManager;
  final MeasurementRowLayout layout;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;
  final String value;
  final String unit;
  final String statistic;
  final TextStyle measurementStyle;
  final TextStyle unitStyle;
  final TextStyle fullUnitStyle;
  final bool expandable;
  final bool simplerUi;

  static const double _halfWidthNonExpandable = 48.0;
  static const double _halfWidthExpandable = 48.0;

  @override
  Widget build(BuildContext context) {
    if (layout == MeasurementRowLayout.divider) {
      return const Divider();
    }

    // Determine styles based on iconColor (if provided, apply it to units/icons)
    final effectiveIconColor = iconColor ?? themeManager.getBlueColor();
    final effectiveUnitStyle = iconColor != null ? unitStyle.apply(color: iconColor) : unitStyle;
    final effectiveFullUnitStyle = iconColor != null
        ? fullUnitStyle.apply(color: iconColor)
        : fullUnitStyle;

    final List<Widget> rowChildren = [];

    if (layout == MeasurementRowLayout.standard) {
      rowChildren.addAll([
        Icon(icon, color: effectiveIconColor, size: iconSize),
        const Spacer(),
        Text(value, style: measurementStyle),
        SizedBox(
          width: iconSize * (expandable ? 1.3 : 2),
          child: Center(child: Text(unit, maxLines: 2, style: effectiveFullUnitStyle)),
        ),
      ]);
    } else {
      // split layout
      rowChildren.addAll([
        SizedBox(
          width: expandable ? _halfWidthExpandable : _halfWidthNonExpandable,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text(value, style: measurementStyle)],
          ),
        ),
        Column(
          children: [
            Icon(icon, color: effectiveIconColor, size: iconSize / 2),
            SizedBox(
              width: iconSize * (expandable ? 0.65 : 1),
              child: Center(child: Text(unit, maxLines: 2, style: effectiveUnitStyle)),
            ),
          ],
        ),
        SizedBox(
          width: expandable ? _halfWidthExpandable : _halfWidthNonExpandable,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text(statistic, style: measurementStyle)],
          ),
        ),
      ]);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowChildren,
    );
  }
}
