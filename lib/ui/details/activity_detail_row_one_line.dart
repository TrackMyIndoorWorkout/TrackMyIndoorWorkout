import 'activity_detail_row_base.dart';

class ActivityDetailRowOneLine extends ActivityDetailRowBase {
  const ActivityDetailRowOneLine({
    super.key,
    required super.themeManager,
    required super.icon,
    required super.iconSize,
    required super.text,
    required super.textStyle,
  }) : super(
          unitText: "",
          unitStyle: null,
          spacer: false,
          forceOneLine: true,
          fitHorizontally: false,
        );
}
