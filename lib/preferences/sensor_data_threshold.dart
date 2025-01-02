import 'ftms_data_threshold.dart';

const sensorDataThreshold = "Sensor Data Threshold (ms)";
const sensorDataThresholdTag = "sensor_data_threshold";
const sensorDataThresholdMin = ftmsDataThresholdMin;
const sensorDataThresholdDefault = ftmsDataThresholdDefault;
const sensorDataThresholdMax = ftmsDataThresholdMax;
const sensorDataThresholdDivisions = (sensorDataThresholdMax - sensorDataThresholdMin) ~/ 10;
const sensorDataThresholdDescription = "The rate at which a new measurement "
    "record will be generated from the merge of the incoming data "
    "from primary and secondary sensors since the last record. "
    "If there's no incoming data an record is enforced.";
