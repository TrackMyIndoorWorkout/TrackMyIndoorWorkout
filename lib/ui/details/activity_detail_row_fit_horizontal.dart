import 'package:flutter/widgets.dart';
import 'activity_detail_row_base.dart';

class ActivityDetailRowFitHorizontal extends ActivityDetailRowBase {
  const ActivityDetailRowFitHorizontal({
    Key? key,
    themeManager,
    icon,
    iconSize,
    text,
    textStyle,
    unitText,
    unitStyle,
  }) : super(
          key: key,
          themeManager: themeManager,
          icon: icon,
          iconSize: iconSize,
          text: text,
          textStyle: textStyle,
          unitText: unitText,
          unitStyle: unitStyle,
          spacer: false,
          forceOneLine: false,
          fitHorizontally: true,
        );
}
