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
const onStageStatisticsTypeDescription = "Select the on-stage statistics type "
    "for non cumulative measurement metrics.";
const onStageStatisticsTypeDefault = onStageStatisticsTypeNone;
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
    "Alternating between average and maximum once per second.";

const onStageStatisticsAlternationDuration = "Scan Duration (s)";
const onStageStatisticsAlternationDurationTag = "On-stage statistics alternation period duration";
const onStageStatisticsAlternationDurationMin = 1;
const onStageStatisticsAlternationDurationDefault = 3;
const onStageStatisticsAlternationDurationMax = 10;
const onStageStatisticsAlternationDurationDivisions =
    onStageStatisticsAlternationDurationMax - onStageStatisticsAlternationDurationMin;
const onStageStatisticsAlternationDurationDescription =
    "Duration in seconds statistics type will stay before alternating.";
