const deviceInformationUuid = '180a';
const fitnessMachineUuid = '1826';
const treadmillUuid = '2acd';
const indoorBikeUuid = '2ad2';
const rowerDeviceUuid = '2ad1';
const crossTrainerUuid = '2ace';
const machineFeatureUuid = '2acc';
const deviceNameUuid = '2a00';
const appearanceUuid = '2a01';
const modelNumberUuid = '2a24';
const serialNumberUuid = '2a25';
const firmwareRevisionUuid = '2a26';
const hardwareRevisionUuid = '2a27';
const softwareRevisionUuid = '2a28';
const manufacturerNameUuid = '2a29';

const ftmsSportCharacteristics = [treadmillUuid, indoorBikeUuid, rowerDeviceUuid];

const batteryServiceUuid = '180f';
const batteryLevelUuid = '2a19';

const heartRateServiceUuid = '180d';
const heartRateMeasurementUuid = '2a37';

const cyclingCadenceServiceUuid = '1816';
const cyclingCadenceMeasurementUuid = '2a5b';

const cyclingPowerServiceUuid = '1818';
const cyclingPowerMeasurementUuid = '2a63';
const cyclingPowerFeatureUuid = '2a65';

const runningCadenceServiceUuid = '1814';
const runningCadenceMeasurementUuid = '2a53';

const precorServiceUuid = 'ee07';
const precorMeasurementUuid = 'e01d';

const userDataServiceUuid = '181c';
const weightCharacteristicUuid = '2a98';
const weightSuccessOpcode = 0x13;
const fitnessMachineStatusUuid = '2ada';
const fitnessMachineControlPointUuid = '2ad9';
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
