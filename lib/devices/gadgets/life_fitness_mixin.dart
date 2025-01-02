import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../devices/bluetooth_device_ex.dart';
import '../../devices/gatt/generic.dart';
import '../../devices/life_fitness.dart';
import '../../persistence/athlete.dart';
import '../../preferences/athlete_email.dart';
import '../../preferences/athlete_name.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/logging.dart';
import '../../utils/user_data.dart';

mixin LifeFitnessMixin {
  static const String lfNamePrefix = "LF";
  static const String lfManufacturer = "LifeFitness";
  StreamSubscription? lfStatusSubscription;

  Future<void> prePumpConfig(List<BluetoothService> svcs, Athlete athlete, int logLvl) async {
    const lfLongerDelay = Duration(milliseconds: 2000);
    const lfShorterDelay = Duration(milliseconds: 500);

    final lfControlPoint = BluetoothDeviceEx.filterService(svcs, lifeFitnessControlServiceUuid);
    final lfStatus1 = BluetoothDeviceEx.filterCharacteristic(
        lfControlPoint?.characteristics, lifeFitnessStatus1Uuid);
    try {
      await lfStatus1?.setNotifyValue(true);
      // TODO: should we sign up for any characteristics on the lfControl1 and lfControl2?
      lfStatusSubscription = lfStatus1?.lastValueStream.listen((controlResponse) async {
        if (logLvl >= logLevelInfo) {
          Logging().log(logLvl, logLevelInfo, lfNamePrefix, "lfStatus1 statusSub",
              controlResponse.toString());
        }
      });
    } on Exception catch (e) {
      if (e is PlatformException && e.code != 'setNotifyValue') {
        rethrow;
      }
    }

    await Future.delayed(lfLongerDelay);
    final lfControl1 = BluetoothDeviceEx.filterCharacteristic(
        lfControlPoint?.characteristics, lifeFitnessControl1Uuid);
    try {
      await lfControl1?.write([lifeFitnessUserControl1MagicNumber1]);
    } on Exception catch (e, stack) {
      Logging().logException(logLvl, lfNamePrefix, "prePumpConfig", "lfControl1.write 1", e, stack);
    }

    await Future.delayed(lfLongerDelay);
    final prefService = Get.find<BasePrefService>();
    final userData = BluetoothDeviceEx.filterService(svcs, lifeFitnessUserServiceUuid);
    // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.first_name.xml
    // UTF-8s
    final firstNameData = BluetoothDeviceEx.filterCharacteristic(
        userData?.characteristics, userFirstNameCharacteristicUuid);
    try {
      final firstName = prefService.get<String>(athleteFirstNameTag) ?? athleteFirstNameDefault;
      await firstNameData?.write(firstName.codeUnits + [0x00]);
    } on Exception catch (e, stack) {
      Logging()
          .logException(logLvl, lfNamePrefix, "prePumpConfig", "firstNameData.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.last_name.xml
    // UTF-8s
    final lastNameData = BluetoothDeviceEx.filterCharacteristic(
        userData?.characteristics, userLastNameCharacteristicUuid);
    try {
      final lastName = prefService.get<String>(athleteLastNameTag) ?? athleteLastNameDefault;
      await lastNameData?.write(lastName.codeUnits + [0x00]);
    } on Exception catch (e, stack) {
      Logging().logException(logLvl, lfNamePrefix, "prePumpConfig", "lastNameData.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.email_address.xml
    // UTF-8s
    final emailData = BluetoothDeviceEx.filterCharacteristic(
        userData?.characteristics, userEmailCharacteristicUuid);
    try {
      final email = prefService.get<String>(athleteEmailTag) ?? athleteEmailDefault;
      await emailData?.write(email.codeUnits + [0x00]);
    } on Exception catch (e, stack) {
      Logging()
          .logException(logLvl, lfNamePrefix, "prePumpConfig", "userEmailData.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.age.xml
    final ageData = BluetoothDeviceEx.filterCharacteristic(
        userData?.characteristics, userAgeCharacteristicUuid);
    try {
      await ageData?.write([athlete.age]);
    } on Exception catch (e, stack) {
      Logging().logException(logLvl, lfNamePrefix, "prePumpConfig", "userAgeData.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.gender.xml
    // uint8 enum: 0 - male, 1 - female, 2 - undef
    final genderData = BluetoothDeviceEx.filterCharacteristic(
        userData?.characteristics, userGenderCharacteristicUuid);
    try {
      await genderData?.write([athlete.isMale ? 0 : 1]);
    } on Exception catch (e, stack) {
      Logging()
          .logException(logLvl, lfNamePrefix, "prePumpConfig", "userGenderData.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.language.xml
    // utf8s ISO639-1 https://en.wikipedia.org/w/index.php?title=List_of_ISO_639-1_codes&redirect=no
    final languageData = BluetoothDeviceEx.filterCharacteristic(
        userData?.characteristics, userLanguageCharacteristicUuid);
    try {
      await languageData?.write([0x65, 0x6E]); // "en"
    } on Exception catch (e, stack) {
      Logging().logException(logLvl, lfNamePrefix, "prePumpConfig", "languageData.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    final unk1Data =
        BluetoothDeviceEx.filterCharacteristic(userData?.characteristics, lifeFitnessUserUnk1Uuid);
    try {
      // TODO: should we break the magic number up into two chunks at the 20 byte mark?
      // The MTU is 672, but Qdomyos does this chop: initData2a and initData2b
      // https://github.com/cagnulein/qdomyos-zwift/blame/5a6afbb500e5937c6808304577c6cdc4269a87c9/src/devices/lifefitnesstreadmill/lifefitnesstreadmill.cpp#L97
      await unk1Data?.write(lifeFitnessUserUnk1MagicNumber);
    } on Exception catch (e, stack) {
      Logging().logException(logLvl, lfNamePrefix, "prePumpConfig", "unk1Data.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    final unk2Data =
        BluetoothDeviceEx.filterCharacteristic(userData?.characteristics, lifeFitnessUserUnk2Uuid);
    try {
      await unk2Data?.write([lifeFitnessUserUnk2MagicNumber]);
    } on Exception catch (e, stack) {
      Logging().logException(logLvl, lfNamePrefix, "prePumpConfig", "unk2Data.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.weight.xml
    // uint16, kg with 0.005 resolution
    final weightData = BluetoothDeviceEx.filterCharacteristic(
        userData?.characteristics, userWeightCharacteristicUuid);
    final weightBytes = getWeightBytes(athlete.weight, athlete.si);
    final weightLsb = weightBytes.item1;
    final weightMsb = weightBytes.item2;
    try {
      await weightData?.write([weightLsb, weightMsb]);
    } on Exception catch (e, stack) {
      Logging().logException(logLvl, lfNamePrefix, "prePumpConfig", "weightData.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.height.xml
    // uint16, meters with 0.01 precision (= centimeters)
    final heightData = BluetoothDeviceEx.filterCharacteristic(
        userData?.characteristics, userHeightCharacteristicUuid);
    try {
      await heightData?.write([athlete.height % maxUint8, athlete.height ~/ maxUint8]);
    } on Exception catch (e, stack) {
      Logging().logException(logLvl, lfNamePrefix, "prePumpConfig", "heightData.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    final lfControl2 = BluetoothDeviceEx.filterCharacteristic(
        lfControlPoint?.characteristics, lifeFitnessControl2Uuid);
    try {
      await lfControl2?.write(lifeFitnessUserControl2MagicNumber);
    } on Exception catch (e, stack) {
      Logging().logException(logLvl, lfNamePrefix, "prePumpConfig", "lfControl2.write", e, stack);
    }

    await Future.delayed(lfShorterDelay);
    try {
      await lfControl1?.write([lifeFitnessUserControl1MagicNumber2]);
    } on Exception catch (e, stack) {
      Logging().logException(logLvl, lfNamePrefix, "prePumpConfig", "lfControl1.write 2", e, stack);
    }
  }

  void stopWorkoutExt() {
    lfStatusSubscription?.cancel();
  }
}
