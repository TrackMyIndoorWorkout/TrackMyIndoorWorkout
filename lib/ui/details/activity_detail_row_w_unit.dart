import 'activity_detail_row_base.dart';

class ActivityDetailRowWithUnit extends ActivityDetailRowBase {
  const ActivityDetailRowWithUnit({
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
          spacer: true,
          forceOneLine: false,
          fitHorizontally: true,
        );
}
