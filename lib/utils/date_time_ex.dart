extension DateTimeEx on DateTime {
  static String get isoDateTime => DateTime.now().toUtc().toIso8601String();
  static String get namePart => isoDateTime.replaceAll(RegExp(r'[^\w\s]+'), '');
}
