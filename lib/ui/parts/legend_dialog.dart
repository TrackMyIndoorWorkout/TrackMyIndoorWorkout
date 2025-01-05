import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

Future<void> legendDialog(List<Tuple2<IconData, String>> legendItems, BuildContext context) async {
  final fontSize = Theme.of(context).textTheme.displayMedium!.fontSize!;
  await Get.defaultDialog(
    title: 'Legend:',
    content: SizedBox(
      height: min(Get.mediaQuery.size.height - 4 * fontSize, legendItems.length * fontSize),
      width: Get.mediaQuery.size.width - 2 * fontSize,
      child: ListView(
        shrinkWrap: true,
        children: legendItems
            .map((i) => ListTile(
                  leading: Icon(i.item1),
                  title: TextOneLine(
                    i.item2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(growable: false),
      ),
    ),
    textConfirm: "Dismiss",
    onConfirm: () => Get.close(1),
  );
}
