const DEVICE_INFORMATION_ID = '180a';
const FITNESS_MACHINE_ID = '1826';
const TREADMILL_ID = '2acd';
const INDOOR_BIKE_ID = '2ad2';
const ROWER_DEVICE_ID = '2ad1';
const CROSS_TRAINER_ID = '2ace';
const DEVICE_NAME_ID = '2a00';
const APPEARANCE_ID = '2a01';
const MODEL_NUMBER_ID = '2a24';
const SERIAL_NUMBER_ID = '2a25';
const FIRMWARE_REVISION_ID = '2a26';
const HARDWARE_REVISION_ID = '2a27';
const SOFTWARE_REVISION_ID = '2a28';
const MANUFACTURER_NAME_ID = '2a29';

const FTMS_SPORT_CHARACTERISTICS = [TREADMILL_ID, INDOOR_BIKE_ID, ROWER_DEVICE_ID];

const BATTERY_SERVICE_ID = '180f';
const BATTERY_LEVEL_ID = '2a19';

const HEART_RATE_SERVICE_ID = '180d';
const HEART_RATE_MEASUREMENT_ID = '2a37';

const CYCLING_CADENCE_SERVICE_ID = '1816';
const CYCLING_CADENCE_MEASUREMENT_ID = '2a5b';

const RUNNING_CADENCE_SERVICE_ID = '1814';
const RUNNING_CADENCE_MEASUREMENT_ID = '2a53';

const PRECOR_SERVICE_ID = 'ee07';
const PRECOR_MEASUREMENT_ID = 'e01d';

const USER_DATA_SERVICE = '181c';
const WEIGHT_CHARACTERISTIC = '2a98';
const WEIGHT_SUCCESS_OPCODE = 0x13;
const FITNESS_MACHINE_STATUS = '2ada';
const FITNESS_MACHINE_FEATURE = '2acc';
// Read features
const AVERAGE_SPEED_SUPPORTED = 0x0001;
const CADENCE_SUPPORTED = 0x0002;
const TOTAL_DISTANCE_SUPPORTED = 0x0004;
const INCLINATION_SUPPORTED = 0x0008;
const ELEVATION_GAIN_SUPPORTED = 0x0010;
const PACE_SUPPORTED = 0x0020;
const STEP_COUNT_SUPPORTED = 0x0040;
const RESISTANCE_LEVEL_SUPPORTED = 0x0080;
const STRIDE_COUNT_SUPPORTED = 0x0100;
const EXPENDED_ENERGY_SUPPORTED = 0x0200;
const HEART_RATE_MEASUREMENT_SUPPORTED = 0x0400;
const METABOLIC_EQUIVALENT_SUPPORTED = 0x0800;
const ELAPSED_TIME_SUPPORTED = 0x1000;
const REMAINING_TIME_SUPPORTED = 0x2000;
const POWER_MEASUREMENT_SUPPORTED = 0x4000;
const FORCE_ON_BELT_AND_POWER_OUTPUT_SUPPORTED = 0x8000;
const USER_DATA_RETENTION_SUPPORTED = 0x10000;
const READ_FEATURE_TEXTS = [
  "Average Speed",
  "Cadence",
  "Total Distance",
  "Inclination",
  "Elevation Gain",
  "Pace",
  "Step Count",
  "Resistance Level",
  "Stride Count",
  "Expended Energy",
  "Heart Rate Measurement",
  "Metabolic Equivalent",
  "Elapsed Time",
  "Remaining Time",
  "Power Measurement",
  "Force on Belt and Power Output",
  "User Data Retention",
];
// Write features
const SPEED_TARGET_SETTING_SUPPORTED = 0x0001;
const INCLINATION_TARGET_SETTING_SUPPORTED = 0x0002;
const RESISTANCE_TARGET_SETTING_SUPPORTED = 0x0004;
const POWER_TARGET_SETTING_SUPPORTED = 0x0008;
const HEART_RATE_TARGET_SETTING_SUPPORTED = 0x0010;
const TARGETED_EXPENDED_ENERGY_CONFIGURATION_SUPPORTED = 0x0020;
const TARGETED_STEP_NUMBER_CONFIGURATION_SUPPORTED = 0x0040;
const TARGETED_STRIDE_NUMBER_CONFIGURATION_SUPPORTED = 0x0080;
const TARGETED_DISTANCE_CONFIGURATION_SUPPORTED = 0x0100;
const TARGETED_TRAINING_TIME_CONFIGURATION_SUPPORTED = 0x0200;
const TARGETED_TIME_IN_TWO_HEART_RATE_ZONES_CONFIGURATION_SUPPORTED = 0x0400;
const TARGETED_TIME_IN_THREE_HEART_RATE_ZONES_CONFIGURATION_SUPPORTED = 0x0800;
const TARGETED_TIME_IN_FIVE_HEART_RATE_ZONES_CONFIGURATION_SUPPORTED = 0x1000;
const INDOOR_BIKE_SIMULATION_PARAMETERS_SUPPORTED = 0x2000;
const WHEEL_CIRCUMFERENCE_CONFIGURATION_SUPPORTED = 0x4000;
const SPIN_DOWN_CONTROL_SUPPORTED = 0x8000;
const TARGETED_CADENCE_CONFIGURATION_SUPPORTED = 0x10000;
const WRITE_FEATURE_TEXTS = [
  "Speed Target Setting",
  "Inclination Target Setting",
  "Resistance Target Setting",
  "Power Target Setting",
  "Heart Rate Target Setting",
  "Targeted Expended Energy Configuration",
  "Targeted Step Number Configuration",
  "Targeted Stride Number Configuration",
  "Targeted Distance Configuration",
  "Targeted Training Time Configuration",
  "Targeted Time in Two Heart Rate Zones Configuration",
  "Targeted Time in Three Heart Rate Zones Configuration",
  "Targeted Time in Five Heart Rate Zones Configuration",
  "Indoor Bike Simulation Parameters",
  "Wheel Circumference Configuration",
  "Spin Down Control",
  "Targeted Cadence Configuration",
];
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.supported_speed_range.xml
const SUPPORTED_SPEED_RANGE = '2ad4';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.supported_inclination_range.xml
const SUPPORTED_INCLINATION_RANGE = '2ad5';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.supported_resistance_level_range.xml
const SUPPORTED_RESISTANCE_LEVEL = '2ad6';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.supported_heart_rate_range.xml
const SUPPORTED_HEART_RATE_RANGE = '2ad7';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.supported_power_range.xml
const SUPPORTED_POWER_RANGE = '2ad8';

const FITNESS_MACHINE_CONTROL_POINT = '2ad9';
// Control opcodes: Table 4.15: Fitness Machine Control Point Procedure Requirements
const REQUEST_CONTROL = 0x00;
const RESET_CONTROL = 0x01;
const SET_RESISTANCE_LEVEL_CONTROL = 0x04;
const START_OR_RESUME_CONTROL = 0x07;
const STOP_OR_PAUSE_CONTROL = 0x08;
const STOP_CONTROL_INFO = 0x01;
const PAUSE_CONTROL_INFO = 0x02;
const SPIN_DOWN_CONTROL = 0x13;
// More
const SPIN_DOWN_STATUS = 0x14;
const SPIN_DOWN_START_COMMAND = 0x01;
const RESPONSE_OPCODE = 0x80;
// Response codes, FTMS Table 4.24
const SUCCESS_RESPONSE = 0x01;
const OPCODE_NOT_SUPPORTED = 0x02;
const INVALID_PARAMETER = 0x03;
const OPERATION_FAILED = 0x04;
const CONTROL_NOT_PERMITTED = 0x05;
// Spin Down statuses
const SPIN_DOWN_STATUS_REQUESTED = 0x01;
const SPIN_DOWN_STATUS_SUCCESS = 0x02;
const SPIN_DOWN_STATUS_ERROR = 0x03;
const SPIN_DOWN_STATUS_STOP_PEDALING = 0x04;
