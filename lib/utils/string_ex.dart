extension StringEx on String {
  String uuidString() {
    return substring(4, 8).toLowerCase();
  }
}
