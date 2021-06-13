import 'package:flutter/material.dart';

class RowConfiguration {
  final IconData icon;
  final String unit;
  final bool expandable;

  RowConfiguration({
    required this.icon,
    required this.unit,
    this.expandable = true,
  });
}
