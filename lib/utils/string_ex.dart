extension StringEx on String {
  String uuidString() {
    return this.substring(4, 8).toLowerCase();
  }
}
