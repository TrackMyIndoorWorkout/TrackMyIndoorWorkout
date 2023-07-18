import 'constants.dart';

class AddressNames {
  late final Map<String, String> _addressNames;

  AddressNames() {
    _addressNames = <String, String>{};
  }

  bool addAddressName(String address, String name) {
    if (name == unnamedDevice) {
      return false;
    }

    _addressNames[address] = name;

    return true;
  }

  String getAddressName(String address, String name) {
    if (name.isNotEmpty) {
      return name;
    }

    return _addressNames[address] ?? unnamedDevice;
  }
}
