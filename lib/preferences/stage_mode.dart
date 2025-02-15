import 'package:flutter/material.dart';

const instantOnStage = "Instantly On-Stage";
const instantOnStageTag = "instant_on_stage";
const instantOnStageDefault = true;
const instantOnStageDescription =
    "The in-workout statistics are calculated only when the athlete is "
    "'on stage'. On: The athlete is immediately on stage after workout start. "
    "Off: The athlete has to manually activate, stop, and restart stage time "
    "via the checkered flag menu.";

const onStageStatisticsType = "On-Stage Statistics Type";
const onStageStatisticsTypeTag = "on_stage_statistics_type";
const onStageStatisticsTypeDescription =
    "Select the on-stage statistics type "
    "for non cumulative measurement metrics.";
const onStageStatisticsTypeDefault = onStageStatisticsTypeAlternating;
const onStageStatisticsTypeNone = "none";
const onStageStatisticsTypeNoneTitle = "None";
const onStageStatisticsTypeNoneDescription = "Don't display statistics";
const onStageStatisticsTypeAverage = "average";
const onStageStatisticsTypeAverageTitle = "Average";
const onStageStatisticsTypeAverageDescription = "Display the average";
const onStageStatisticsTypeMaximum = "maximum";
const onStageStatisticsTypeMaximumTitle = "Maximum";
const onStageStatisticsTypeMaximumDescription = "Display the maximum";
const onStageStatisticsTypeAlternating = "alternating";
const onStageStatisticsTypeAlternatingTitle = "Alternating";
const onStageStatisticsTypeAlternatingDescription =
    "Alternating between average and maximum by period set below.";

const onStageStatisticsAlternationPeriod = "Stat Alternation Period (s)";
const onStageStatisticsAlternationPeriodTag = "on_stage_statistics_alternation_period";
const onStageStatisticsAlternationPeriodMin = 1;
const onStageStatisticsAlternationPeriodDefault = onStageStatisticsAlternationPeriodMin;
const onStageStatisticsAlternationPeriodMax = 10;
const onStageStatisticsAlternationPeriodDivisions =
    onStageStatisticsAlternationPeriodMax - onStageStatisticsAlternationPeriodMin;
const onStageStatisticsAlternationPeriodDescription =
    "Duration in seconds statistics type will stay before alternating.";

const averageChartColor = "Avg. Stat. Color";
const averageChartColorTag = "average_stat_color";
final averageChartColorDefault = Colors.deepOrangeAccent.toARGB32();
const averageChartColorDescription = "Color of the average line on the charts.";

const maximumChartColor = "Max. Stat. Color";
const maximumChartColorTag = "maximum_stat_color";
final maximumChartColorDefault = Colors.red.toARGB32();
const maximumChartColorDescription = "Color of the maximum line on the charts.";
