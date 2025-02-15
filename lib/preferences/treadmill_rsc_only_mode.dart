const treadmillRscOnlyMode = "FTMS Treadmill RSC Only Mode";
const treadmillRscOnlyModeTag = "ftms_treadmill_rsc_only_mode";
const treadmillRscOnlyModeDescription =
    "Technogym Run (not MyRun, but the newer Run)"
    "poses as an FTMS Treadmill but only transmits data as an RSC sensor. "
    "We need to know this to not wait for an FTMS data which never arrives. "
    "When to use a workaround to handle this? "
    "Auto = Technogym Run would be detected by manufacturer and device name. "
    "Always = Apply the workaround to all treadmills (useful for a home gym). "
    "Never = Don't apply the workaround in any case.";
const treadmillRscOnlyModeAuto = "auto";
const treadmillRscOnlyModeAutoDescription = "Auto";
const treadmillRscOnlyModeAlways = "always";
const treadmillRscOnlyModeAlwaysDescription = "Always";
const treadmillRscOnlyModeNever = "never";
const treadmillRscOnlyModeNeverDescription = "Never";
const treadmillRscOnlyModeDefault = treadmillRscOnlyModeAuto;
