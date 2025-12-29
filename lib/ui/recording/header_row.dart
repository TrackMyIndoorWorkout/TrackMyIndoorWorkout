import 'package:flutter/material.dart';
import '../../utils/theme_manager.dart';
import '../../preferences/palette_spec.dart';
import '../../preferences/stage_mode.dart';
import '../../preferences/time_display_mode.dart';
import '../../devices/gadgets/fitness_equipment.dart';

class RecordingHeaderRow extends StatelessWidget {
  const RecordingHeaderRow({
    super.key,
    required this.themeManager,
    required this.onStageStatisticsType,
    required this.movingTimeDisplay,
    required this.elapsedTimeDisplay,
    required this.singleTimeDisplay,
    required this.timeDisplayMode,
    required this.workoutState,
    required this.paletteSpec,
    required this.baseTimeStyle,
    required this.measurementStyle,
    required this.iconSize,
  });

  final ThemeManager themeManager;
  final String onStageStatisticsType;
  final String movingTimeDisplay;
  final String elapsedTimeDisplay;
  final String singleTimeDisplay;
  final String timeDisplayMode;
  final WorkoutState workoutState;
  final PaletteSpec? paletteSpec;
  final TextStyle baseTimeStyle;
  final TextStyle measurementStyle;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    TextStyle effectiveTimeStyle = baseTimeStyle;

    if (timeDisplayMode == timeDisplayModeHIITMoving &&
        workoutState != WorkoutState.waitingForFirstMove) {
      final timeColorIndex = [WorkoutState.justPaused, WorkoutState.paused].contains(workoutState)
          ? 0
          : 4;
      effectiveTimeStyle = measurementStyle.apply(
        color: paletteSpec?.lightFgPalette[5]![timeColorIndex],
      );
    }

    var timeIcon =
        (timeDisplayMode == timeDisplayModeHIITMoving &&
            [WorkoutState.startedMoving, WorkoutState.moving].contains(workoutState))
        ? themeManager.getRedIcon(Icons.timer, iconSize)
        : themeManager.getBlueIcon(Icons.timer, iconSize);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: onStageStatisticsType != onStageStatisticsTypeNone
          ? [
              const Spacer(),
              Text(movingTimeDisplay, style: effectiveTimeStyle),
              timeIcon,
              const Spacer(),
              Text(elapsedTimeDisplay, style: effectiveTimeStyle),
            ]
          : [
              timeIcon,
              Text(singleTimeDisplay, style: effectiveTimeStyle),
              SizedBox(width: iconSize / 4),
            ],
    );
  }
}
