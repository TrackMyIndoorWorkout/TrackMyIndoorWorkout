import 'package:flutter/widgets.dart';
import 'activity_detail_row_base.dart';

class ActivityDetailRowWithSpacer extends ActivityDetailRowBase {
  const ActivityDetailRowWithSpacer({
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
          spacer: true,
          forceOneLine: false,
          fitHorizontally: false,
        );
}
