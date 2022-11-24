import 'generic.dart';

const dataStreamGapWatchdog = "Data Stream Gap Watchdog Timer";
const dataStreamGapWatchdogTag = "data_stream_gap_watchdog_timer";
const dataStreamGapWatchdogIntTag = dataStreamGapWatchdogTag + intTagPostfix;
const dataStreamGapWatchdogMin = 0;
const dataStreamGapWatchdogOldDefault = 5;
const dataStreamGapWatchdogDefault = 30;
const dataStreamGapWatchdogMax = 50;
const dataStreamGapWatchdogDivisions = dataStreamGapWatchdogMax - dataStreamGapWatchdogMin;
const dataStreamGapWatchdogDescription = "How many seconds of data gap considered "
    "as a disconnection. A watchdog would finish the workout and can trigger sound warnings as well. "
    "Zero means disabled.";
