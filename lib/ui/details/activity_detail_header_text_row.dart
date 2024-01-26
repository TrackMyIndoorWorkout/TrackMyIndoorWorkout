import 'package:flutter/widgets.dart';

import 'activity_detail_header_row_base.dart';

class ActivityDetailHeaderTextRow extends ActivityDetailHeaderRowBase {
  ActivityDetailHeaderTextRow({
    super.key,
    required super.themeManager,
    required super.icon,
    required super.iconSize,
    required text,
    required textStyle,
  }) : super(widget: Text(text, style: textStyle));
}
