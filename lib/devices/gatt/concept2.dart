const c2DeviceInfoServiceUuid = '0010';
const c2ModelNumberUuid = '0011'; // "PM5", 16 bytes
const c2SerialNumberUuid = '0012'; // 9 bytes
const c2HardwareRevisionUuid = '0013'; // 3 bytes
const c2FirmwareRevisionUuid = '0014'; // 20 bytes
const c2ManufacturerNameUuid = '0015'; // "Concept2", 16 bytes
const c2ErgometerMachineTypeUuid = '0016'; // 1 byte, valid for PM5 V150-V299.99

const c2PmControlServiceUuid = '0020';
const c2PmReceiveCharacteristicUuid = '0021'; // Control command in form of CSAFE frame
const c2PmTransmitCharacteristicUuid = '0022'; // Response to command in form of CSAFE frame

const c2ErgPrimaryServiceUuid = '0030'; // C2 Erg Service
const c2ErgGeneralStatusUuid = '0031'; // 19 bytes (elapsed time, distance, ...)
const c2ErgAdditionalStatus1Uuid =
    '0032'; // 17 bytes (elapsed time, speed, stroke rate, HR, pace, erg type, ...)
const c2ErgAdditionalStatus2Uuid = '0033'; // 20 bytes (elapsed time, total calories, ...)
const c2ErgStatusSamplingRateUuid = '0034'; // 1 byte
const c2ErgStrokeDataUuid = '0035'; // 20 bytes (avg drive force, stroke count, ...)
const c2ErgAdditionalStrokeDataUuid =
    '0036'; // 15 bytes (elapsed time, stroke power, stroke calories, stroke count, ...)
const c2ErgSplitIntervalDataUuid = '0037'; // 18 bytes
const c2ErgAdditionalSplitIntervalDataUuid = '0038'; // 19 bytes (elapsed time, erg type, ...)
const c2ErgWorkoutSummaryDataUuid = '0039'; // 20 bytes
const c2ErgWorkoutAdditionalSummaryDataUuid = '003a'; // 19 bytes
const c2ErgHRBeltInformationUuid = '003b'; // 6 bytes
const c2ForceCurveDataUuid = '003d'; // 2-288 bytes
const c2MultiplexedInformationUuid = '0080'; // up to 20 bytes
