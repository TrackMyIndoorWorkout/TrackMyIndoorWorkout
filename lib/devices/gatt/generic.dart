// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.service.device_information.xml
const deviceInformationUuid = '180a';
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

// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.service.user_data.xml
const userDataServiceUuid = '181c';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.first_name.xml
// UTF-8s
const userFirstNameCharacteristicUuid = '2a8a';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.last_name.xml
// UTF-8s
const userLastNameCharacteristicUuid = '2a90';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.email_address.xml
// UTF-8s
const userEmailCharacteristicUuid = '2a87';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.age.xml
// uint8
const userAgeCharacteristicUuid = '2a80';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.gender.xml
// uint8 enum: 0 - male, 1 - female, 2 - undef
const userGenderCharacteristicUuid = '2a8c';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.language.xml
// utf8s ISO639-1 https://en.wikipedia.org/w/index.php?title=List_of_ISO_639-1_codes&redirect=no
const userLanguageCharacteristicUuid = '2aa2';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.weight.xml
// uint16, kg with 0.005 resolution
const userWeightCharacteristicUuid = '2a98';
// https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.height.xml
// uint16, meters with 0.01 precision
const userHeightCharacteristicUuid = '2a8e';

const userDataSetSuccessOpcode = 0x13;
