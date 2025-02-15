import 'activity_detail_row_base.dart';

class ActivityDetailRowFitHorizontal extends ActivityDetailRowBase {
  const ActivityDetailRowFitHorizontal({
    super.key,
    required super.themeManager,
    required super.icon,
    required super.iconSize,
    required super.text,
    required super.textStyle,
    required super.unitText,
    super.unitStyle,
  }) : super(spacer: false, forceOneLine: false, fitHorizontally: true);
}
