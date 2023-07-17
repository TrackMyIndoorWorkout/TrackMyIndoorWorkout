import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/address_names.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

void main() {
  test('AddressNames will not modify when it is empty', () async {
    final an = AddressNames();

    const address = "CC:01:76:19:A0:03";
    const name = "Stages IC 021";
    expect(an.getAddressName(address, name), name);
  });

  test('AddressNames will supply Unnamed for empty name when it is empty', () async {
    final an = AddressNames();

    const address = "CC:01:76:19:A0:03";
    expect(an.getAddressName(address, ""), unnamedDevice);
  });

  test('AddressNames will return name and not the stored name if name is not empty', () async {
    final an = AddressNames();
    const address = "CC:01:76:19:A0:03";
    an.addAddressName(address, "Whatever");

    const name = "Stages IC 021";
    expect(an.getAddressName(address, name), name);
  });

  test('AddressNames will return stored name when presented with empty name', () async {
    final an = AddressNames();
    const address = "CC:01:76:19:A0:03";
    const name = "Stages IC 021";
    an.addAddressName(address, name);

    expect(an.getAddressName(address, ""), name);
  });

  test('AddressNames will return last stored name when presented with empty name', () async {
    final an = AddressNames();
    const address = "CC:01:76:19:A0:03";
    an.addAddressName(address, "Whatever");
    const name = "Stages IC 021";
    // Overrides previous name
    an.addAddressName(address, name);

    expect(an.getAddressName(address, ""), name);
  });

  test('AddressNames will return unnamed for empty name when address not found', () async {
    final an = AddressNames();
    const address1 = "CC:01:76:19:A0:03";
    const name = "Stages IC 021";
    an.addAddressName(address1, name);

    const address2 = "ED:7A:58:C4:CA:A0";
    expect(an.getAddressName(address2, ""), unnamedDevice);
  });
}
