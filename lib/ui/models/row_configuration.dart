import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class RowConfiguration {
  final IconData icon;
  final String unit;
  final bool expandable;

  RowConfiguration({
    @required this.icon,
    @required this.unit,
    this.expandable = true,
  })  : assert(icon != null),
        assert(unit != null),
        assert(expandable != null);
}
