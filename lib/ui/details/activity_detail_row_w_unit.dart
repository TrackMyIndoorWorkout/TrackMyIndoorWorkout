import 'activity_detail_row_base.dart';

class ActivityDetailRowWithUnit extends ActivityDetailRowBase {
  const ActivityDetailRowWithUnit({
    super.key,
    required super.themeManager,
    required super.icon,
    required super.iconSize,
    required super.text,
    required super.textStyle,
    required super.unitText,
    super.unitStyle,
  }) : super(spacer: true, forceOneLine: false, fitHorizontally: true);
}
