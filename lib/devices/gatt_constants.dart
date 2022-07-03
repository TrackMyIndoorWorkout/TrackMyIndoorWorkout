// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.service.device_information.xml
const deviceInformationUuid = '180a';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.service.fitness_machine.xml
const fitnessMachineUuid = '1826';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.treadmill_data.xml
const treadmillUuid = '2acd';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.indoor_bike_data.xml
const indoorBikeUuid = '2ad2';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.rower_data.xml
const rowerDeviceUuid = '2ad1';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.cross_trainer_data.xml
const crossTrainerUuid = '2ace';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.stair_climber_data.xml
const stairClimberUuid = '2ad0';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.step_climber_data.xml
const stepClimberUuid = '2acf';
/*
const deviceNameUuid = '2a00';
const appearanceUuid = '2a01';
const modelNumberUuid = '2a24';
const serialNumberUuid = '2a25';
const firmwareRevisionUuid = '2a26';
const hardwareRevisionUuid = '2a27';
const softwareRevisionUuid = '2a28';
*/
const manufacturerNameUuid = '2a29';

const ftmsSportCharacteristics = [treadmillUuid, indoorBikeUuid, rowerDeviceUuid, crossTrainerUuid];

// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.service.battery_service.xml
const batteryServiceUuid = '180f';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.battery_level.xml
const batteryLevelUuid = '2a19';

// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.service.heart_rate.xml
const heartRateServiceUuid = '180d';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.heart_rate_measurement.xml
const heartRateMeasurementUuid = '2a37';

// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.service.cycling_speed_and_cadence.xml
const cyclingCadenceServiceUuid = '1816';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.csc_measurement.xml
const cyclingCadenceMeasurementUuid = '2a5b';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.csc_feature.xml
const cyclingCadenceFeaturesUuid = '2a5c';

// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.service.cycling_power.xml
const cyclingPowerServiceUuid = '1818';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.cycling_power_measurement.xml
const cyclingPowerMeasurementUuid = '2a63';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.cycling_power_feature.xml
const cyclingPowerFeatureUuid = '2a65';

// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.service.running_speed_and_cadence.xml
const runningCadenceServiceUuid = '1814';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.rsc_measurement.xml
const runningCadenceMeasurementUuid = '2a53';

const precorServiceUuid = 'ee07';
const precorMeasurementUuid = 'e01d';

const schwinnX70ServiceUuid = '8980';
const schwinnX70MeasurementUuid = '82a0';
const schwinnX70ControlUuid = 'b3c0';
const schwinnX70ExtraMeasurementUuid = 'f580';

// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.service.user_data.xml
const userDataServiceUuid = '181c';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.weight.xml
const weightCharacteristicUuid = '2a98';
const weightSuccessOpcode = 0x13;
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.fitness_machine_status.xml
const fitnessMachineStatusUuid = '2ada';

// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.fitness_machine_feature.xml
const fitnessMachineFeature = '2acc';
// Read features
const averageSpeedSupported = 0x0001;
const cadenceSupported = 0x0002;
const totalDistanceSupported = 0x0004;
const inclinationSupported = 0x0008;
const elevationGainSupported = 0x0010;
const paceSupported = 0x0020;
const stepCountSupported = 0x0040;
const resistanceLevelSupported = 0x0080;
const strideCountSupported = 0x0100;
const expendedEnergySupported = 0x0200;
const heartRateMeasurementSupported = 0x0400;
const metabolicEquivalentSupported = 0x0800;
const elapsedTimeSupported = 0x1000;
const remainingTimeSupported = 0x2000;
const powerMeasurementSupported = 0x4000;
const forceOnBeltAndPowerOutputSupported = 0x8000;
const userDataRetentionSupported = 0x10000;
const readFeatureTexts = [
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
const speedTargetSettingSupported = 0x0001;
const inclinationTargetSettingSupported = 0x0002;
const resistanceTargetSettingSupported = 0x0004;
const powerTargetSettingSupported = 0x0008;
const heartRateTargetSettingSupported = 0x0010;
const targetedExpendedEnergyConfigurationSupported = 0x0020;
const targetedStepNumberConfigurationSupported = 0x0040;
const targetedStrideNumberConfigurationSupported = 0x0080;
const targetedDistanceConfigurationSupported = 0x0100;
const targetedTrainingTimeConfigurationSupported = 0x0200;
const targetedTimeInTwoHeartRateZonesConfigurationSupported = 0x0400;
const targetedTimeInThreeHeartRateZonesConfigurationSupported = 0x0800;
const targetedTimeInFiveHeartRateZonesConfigurationSupported = 0x1000;
const indoorBikeSimulationParametersSupported = 0x2000;
const wheelCircumferenceConfigurationSupported = 0x4000;
const spinDownControlSupported = 0x8000;
const targetedCadenceConfigurationSupported = 0x10000;
const writeFeatureTexts = [
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
const supportedSpeedRange = '2ad4';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.supported_inclination_range.xml
const supportedInclinationRange = '2ad5';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.supported_resistance_level_range.xml
const supportedResistanceLevel = '2ad6';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.supported_heart_rate_range.xml
const supportedHeartRateRange = '2ad7';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.supported_power_range.xml
const supportedPowerRange = '2ad8';

// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.fitness_machine_control_point.xml
const fitnessMachineControlPointUuid = '2ad9';
// Control opcodes: Table 4.15: Fitness Machine Control Point Procedure Requirements
const requestControl = 0x00;
const resetControl = 0x01;
const setResistanceLevelControl = 0x04;
const startOrResumeControl = 0x07;
const stopOrPauseControl = 0x08;
const stopControlInfo = 0x01;
const pauseControlInfo = 0x02;
const spinDownControl = 0x13;

const spinDownOpcode = 0x13;
const spinDownStatus = 0x14;
const spinDownStartCommand = 0x01;
const controlOpcode = 0x80;
// Response codes, FTMS Table 4.24
const successResponse = 0x01;
const opcodeNotSupported = 0x02;
const invalidParameter = 0x03;
const operationFailed = 0x04;
const controlNotPermitted = 0x05;
// Spin Down statuses
const spinDownStatusRequested = 0x01;
const spinDownStatusSuccess = 0x02;
const spinDownStatusError = 0x03;
const spinDownStatusStopPedaling = 0x04;
