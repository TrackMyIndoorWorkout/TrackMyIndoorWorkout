import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class RowConfiguration {
  final IconData icon;
  final String unit;

  RowConfiguration({@required this.icon, @required this.unit})
      : assert(icon != null),
        assert(unit != null);
}
