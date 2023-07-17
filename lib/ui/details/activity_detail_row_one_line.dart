import 'package:flutter/widgets.dart';
import 'activity_detail_row_base.dart';

class ActivityDetailRowOneLine extends ActivityDetailRowBase {
  const ActivityDetailRowOneLine({
    Key? key,
    themeManager,
    icon,
    iconSize,
    text,
    textStyle,
  }) : super(
          key: key,
          themeManager: themeManager,
          icon: icon,
          iconSize: iconSize,
          text: text,
          textStyle: textStyle,
          unitText: "",
          unitStyle: null,
          spacer: false,
          forceOneLine: true,
          fitHorizontally: false,
        );
}
