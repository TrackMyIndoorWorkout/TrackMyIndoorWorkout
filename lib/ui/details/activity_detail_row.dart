import 'activity_detail_row_base.dart';

class ActivityDetailRow extends ActivityDetailRowBase {
  const ActivityDetailRow({
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
          forceOneLine: false,
          fitHorizontally: false,
        );
}
