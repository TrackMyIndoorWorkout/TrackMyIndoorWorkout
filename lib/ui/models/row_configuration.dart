import 'package:flutter/material.dart';

class RowConfiguration {
  final String title;
  final IconData icon;
  final String unit;
  final bool expandable;

  RowConfiguration({
    required this.title,
    required this.icon,
    required this.unit,
    this.expandable = true,
  });
}
