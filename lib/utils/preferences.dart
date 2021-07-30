import 'dart:io';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tuple/tuple.dart';
import 'constants.dart';

bool isBoundedInteger(String integerString, int minValue, int maxValue) {
  if (integerString.trim().isEmpty) return false;

  final integer = int.tryParse(integerString);
  return integer != null && integer >= minValue && integer <= maxValue;
}

bool isPortNumber(String portString) {
  return isBoundedInteger(portString, 1, MAX_UINT16 - 1);
}

bool isIpPart(String ipAddressPart, bool allowZero) {
  return isBoundedInteger(ipAddressPart, allowZero ? 0 : 1, MAX_BYTE);
}

bool isIpAddress(String ipAddress) {
  if (ipAddress.trim().isEmpty) return false;

  final ipParts = ipAddress.trim().split(".");
  final trimCheck =
      ipParts.fold<bool>(true, (prev, ipPart) => prev && ipPart.length == ipPart.trim().length);
  return ipParts.length == 4 &&
      trimCheck &&
      isIpPart(ipParts[0], false) &&
      isIpPart(ipParts[1], true) &&
      isIpPart(ipParts[2], true) &&
      isIpPart(ipParts[3], true);
}

final dummyAddressTuple = Tuple2<String, int>("", 0);

Tuple2<String, int> parseIpAddress(String ipAddress) {
  if (ipAddress.trim().isEmpty) return dummyAddressTuple;

  final addressParts = ipAddress.trim().split(":");
  if (addressParts[0].isEmpty) return dummyAddressTuple;

  int portNumber = HTTPS_PORT;
  if (addressParts.length > 1 && addressParts[1].trim().isNotEmpty) {
    final portNumberString = addressParts[1].trim();
    if (!isPortNumber(portNumberString)) return dummyAddressTuple;

    final parsedPort = int.tryParse(portNumberString);
    if (parsedPort != null && parsedPort > 0) {
      portNumber = parsedPort;
    }
  }
  if (!isIpAddress(addressParts[0])) return dummyAddressTuple;

  return Tuple2<String, int>(addressParts[0], portNumber);
}

List<Tuple2<String, int>> parseIpAddresses(String ipAddresses) {
  List<Tuple2<String, int>> addresses = [];
  if (ipAddresses.trim().isNotEmpty) {
    addresses = ipAddresses.split(",").map((ipAddress) => parseIpAddress(ipAddress)).toList();

    // .whereType<Tuple2<String, int>>() I think reflection could be slower
    addresses.removeWhere((value) => value.item2 == 0);
  }
  return addresses;
}

void applyDataConnectionCheckConfiguration(List<Tuple2<String, int>> addressTuples) {
  if (addressTuples.length > 0) {
    InternetConnectionChecker().addresses = addressTuples
        .map((addressTuple) => AddressCheckOptions(
              InternetAddress(addressTuple.item1),
              port: addressTuple.item2,
            ))
        .toList(growable: false);
  }
}
