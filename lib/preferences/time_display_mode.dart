const timeDisplayMode = "Time Display Mode";
const timeDisplayModeTag = "time_display_mode";
const timeDisplayModeDescription = "Select Time Display Mode.";
const timeDisplayModeDefault = timeDisplayModeMoving;
const timeDisplayModeElapsed = "elapsed";
const timeDisplayModeElapsedTitle = "Elapsed";
const timeDisplayModeElapsedDescription =
    "Display the elapsed time (time advances even when the machine is idle)";
const timeDisplayModeMoving = "moving";
const timeDisplayModeMovingTitle = "Moving";
const timeDisplayModeMovingDescription =
    "Display the moving time (time doesn't move while machine is idle)";
const timeDisplayModeHIITMoving = "hiit";
const timeDisplayModeHIITMovingTitle = "HIIT";
const timeDisplayModeHIITMovingDescription =
    "HIIT mode involves a repeated succession of work and rest intervals. "
    "Time would start from 0 at each workout or rest interval.";

// Deprecated in favor of timeDisplayMode
const movingOrElapsedTime = "Display the Moving or the Elapsed Time";
const movingOrElapsedTimeTag = "moving_or_elapsed_time";
const movingOrElapsedTimeDefault = true;
const movingOrElapsedTimeDescription = "On: Display the moving time (excludes idle periods), "
    "Off: Display the elapsed time (includes idle periods).";
