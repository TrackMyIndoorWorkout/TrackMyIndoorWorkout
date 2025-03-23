import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pref/pref.dart';
import 'package:string_validator/string_validator.dart';
import 'package:tuple/tuple.dart';

import '../preferences/data_connection_addresses.dart';
import 'constants.dart';

bool isBoundedInteger(String integerString, int minValue, int maxValue) {
  if (integerString.trim().isEmpty) return false;

  final integer = int.tryParse(integerString);
  return integer != null && integer >= minValue && integer <= maxValue;
}

bool isPortNumber(String portString) {
  return isBoundedInteger(portString, 1, maxUint16 - 1);
}

const dummyAddressTuple = Tuple2<String, int>("", 0);

Tuple2<String, int> parseNetworkAddress(String networkAddress, [bool ipOnly = true]) {
  if (networkAddress.isEmpty) {
    return dummyAddressTuple;
  }

  final portPosition = networkAddress.lastIndexOf(":");
  if (portPosition < 0) {
    // Port is mandatory
    return dummyAddressTuple;
  }

  final portNumberString = networkAddress.substring(portPosition + 1);
  if (portNumberString.isEmpty) {
    return dummyAddressTuple;
  }

  if (!isPortNumber(portNumberString)) {
    return dummyAddressTuple;
  }

  final parsedPort = int.tryParse(portNumberString);
  if (parsedPort == null || parsedPort <= 0) {
    return dummyAddressTuple;
  }

  String name = networkAddress.substring(0, portPosition);
  if (name.startsWith("[") || name.endsWith("]")) {
    if (!name.startsWith("[") || !name.endsWith("]")) {
      // square bracketing the IPv6 IP is not complete
      return dummyAddressTuple;
    }

    name = name.substring(1, name.length - 1);
  }

  if (!isIP(name) && !name.isIPv6 && (ipOnly || !isFQDN(name))) {
    return dummyAddressTuple;
  }

  return Tuple2<String, int>(name, parsedPort);
}

List<Tuple2<String, int>> parseNetworkAddresses(String networkAddresses, [bool ipOnly = true]) {
  List<Tuple2<String, int>> addresses = [];
  if (networkAddresses.trim().isNotEmpty) {
    addresses =
        networkAddresses.split(",").map((address) => parseNetworkAddress(address, ipOnly)).toList();

    // .whereType<Tuple2<String, int>>() I think reflection could be slower
    addresses.removeWhere((value) => value.item2 == 0);
  }

  return addresses;
}

String addDefaultPortIfMissing(String address) {
  if (address.isEmpty) {
    return "";
  }

  if (address.contains(":")) {
    return address;
  }

  return "$address:443";
}

bool isDummyAddress(Tuple2<String, int> addressTuple) {
  return addressTuple.item1 == dummyAddressTuple.item1 &&
      addressTuple.item2 == dummyAddressTuple.item2;
}

Future<bool> hasInternetConnection() async {
  final prefService = Get.find<BasePrefService>();
  String addressesString =
      prefService.get<String>(dataConnectionAddressesTag) ?? dataConnectionAddressesDefault;
  final List<InternetCheckOption> checkOptions = [];
  if (addressesString.isNotEmpty) {
    final addressTuples = parseNetworkAddresses(addressesString);
    for (final addressTuple in addressTuples) {
      checkOptions.add(
        InternetCheckOption(
          uri: Uri(scheme: "http", host: addressTuple.item1, port: addressTuple.item2),
        ),
      );
    }
  }

  var connectionChecker =
      checkOptions.isEmpty
          ? InternetConnection()
          : InternetConnection.createInstance(
            customCheckOptions: checkOptions,
            useDefaultOptions: false,
          );

  return await connectionChecker.hasInternetAccess;
}
