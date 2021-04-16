import 'package:tuple/tuple.dart';
import 'constants.dart';

bool isBoundedInteger(String integerString, int maxValue) {
  if (integerString == null || integerString.trim().isEmpty) return false;

  final integer = int.tryParse(integerString);
  return integer != null && integer > 0 && integer <= maxValue;
}

bool isPortNumber(String portString) {
  return isBoundedInteger(portString, 65535);
}

bool isIpPart(String ipAddressPart) {
  return isBoundedInteger(ipAddressPart, 255);
}

bool isIpAddress(String ipAddress) {
  if (ipAddress == null || ipAddress.trim().isEmpty) return false;

  final ipParts = ipAddress.split(".");
  return ipParts.length == 4 && ipParts.fold(true, (prev, ipPart) => prev && isIpPart(ipPart));
}

List<Tuple2<String, int>> convertAddressStringToTuples(String addressString) {
  List<Tuple2<String, int>> addresses = [];
  if (addressString != null && addressString.trim().isNotEmpty) {
    addresses = addressString.split(",").map((address) {
      final addressParts = address.trim().split(":");
      if (addressParts[0].isEmpty) return null;

      int portNumber = HTTPS_PORT;
      if (addressParts.length > 1 && addressParts[1].trim().isNotEmpty) {
        final portNumberString = addressString[1].trim();
        if (!isPortNumber(portNumberString)) return null;

        final parsedPort = int.tryParse(portNumberString);
        if (parsedPort != null && parsedPort > 0) {
          portNumber = parsedPort;
        }
      }
      if (!isIpAddress(addressParts[0])) return null;

      return Tuple2<String, int>(addressParts[0], portNumber);
    }).toList(growable: false);
  }
  return addresses;
}
