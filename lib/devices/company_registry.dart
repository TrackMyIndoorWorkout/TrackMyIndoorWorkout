import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import '../utils/constants.dart';

// Bluetooth SIG registered companies
class CompanyRegistry {
  static const blankKey = 1930;
  Map<int, String> registry = {};

  Future<void> loadCompanyIdentifiers() async {
    ByteData namesGzip = await rootBundle.load('assets/CompanyNames.txt.gz');
    final characters = GZipCodec(gzip: true).decode(namesGzip.buffer.asUint8List());
    final namesString = utf8.decode(characters);
    registry = namesString.split('\n').asMap();
  }

  String nameForId(int id) {
    if (!registry.containsKey(id)) return NOT_AVAILABLE;

    return registry[id]!;
  }
}
