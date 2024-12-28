const ftmsDataThreshold = "FTMS Data Threshold (ms)";
const ftmsDataThresholdTag = "ftms_data_threshold";
const ftmsDataThresholdMin = 50;
const ftmsDataThresholdDefault = 480;
const ftmsDataThresholdMax = 1000;
const ftmsDataThresholdDivisions = (ftmsDataThresholdMax - ftmsDataThresholdMin) ~/ 10;
const ftmsDataThresholdDescription = "The rate at which a new measurement "
    "record will be generated from the merge of the incoming data "
    "from the main fitness machine since the last record. "
    "If there's no incoming data an record is enforced.";
