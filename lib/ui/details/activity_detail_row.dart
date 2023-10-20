import 'activity_detail_row_base.dart';

class ActivityDetailRow extends ActivityDetailRowBase {
  const ActivityDetailRow({
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
          forceOneLine: false,
          fitHorizontally: false,
        );
}
