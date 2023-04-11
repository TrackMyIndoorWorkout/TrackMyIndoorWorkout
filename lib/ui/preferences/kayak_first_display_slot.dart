import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/kayak_first_display_configuration.dart';

List<DropdownMenuItem<int>> getKayakFirstDisplayChoices() {
  return kayakFirstDisplayChoices
      .map((c) => DropdownMenuItem<int>(value: c.item1, child: Text(c.item2)))
      .toList(growable: false);
}

PrefDropdown getKayakFirstDisplaySlotPref(
  String prefTag,
  String prefTitle,
  String prefDescription,
) {
  return PrefDropdown<int>(
    title: Text(prefTitle, style: Get.textTheme.headlineSmall!, maxLines: 3),
    pref: prefTag,
    items: getKayakFirstDisplayChoices(),
    fullWidth: false,
  );
}
