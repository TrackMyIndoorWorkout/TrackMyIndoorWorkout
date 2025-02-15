const blockFTMSFeatureRead = "Block FTMS Feature Read";
const blockFTMSFeatureReadTag = "block_ftms_feature_read";
const blockFTMSFeatureReadDefault = false;
const blockFTMSFeatureReadDescription =
    "On: The application won't "
    "read the FTMS feature characteristic. Right now this only affects FTMS "
    "spin down feature support determination (very few devices), nothing else "
    "yet."
    "Off: the application will read FTMS standard machine features such as "
    "resistance range, HR range and more. Not used by anything right now "
    "except spin down control support.";
