const heartRateGapWorkaround = "Heart Rate Data Gap Workaround";
const heartRateGapWorkaroundTag = "heart_rate_gap_workaround";
const heartRateGapWorkaroundSelection = "Heart Rate Data Gap Workaround Selection:";
const dataGapWorkaroundLastPositiveValue = "last_positive_value";
const dataGapWorkaroundLastPositiveValueDescription =
    "Hold the last known positive reading when a zero intermittent reading is encountered";
const dataGapWorkaroundNoWorkaround = "no_workaround";
const dataGapWorkaroundNoWorkaroundDescription =
    "Record any values (including zeros) just as they are read from the device";
const dataGapWorkaroundDoNotWriteZeros = "do_not_write_zeros";
const dataGapWorkaroundDoNotWriteZerosDescription =
    "Don't output any reading when zero data is recorded. Certain standards may not support that";
const heartRateGapWorkaroundDefault = dataGapWorkaroundLastPositiveValue;
