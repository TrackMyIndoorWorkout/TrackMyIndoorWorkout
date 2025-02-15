import 'activity_detail_row_base.dart';

class ActivityDetailRowWithSpacer extends ActivityDetailRowBase {
  const ActivityDetailRowWithSpacer({
    super.key,
    required super.themeManager,
    required super.icon,
    required super.iconSize,
    required super.text,
    required super.textStyle,
  }) : super(
         unitText: "",
         unitStyle: null,
         spacer: true,
         forceOneLine: false,
         fitHorizontally: false,
       );
}
