class WriteSupportParameters {
  late double minimum;
  late double maximum;
  late double increment;
  final int division;
  final int numberBytes;

  WriteSupportParameters(
    List<int> data, {
    this.division = 1,
    this.numberBytes = 2,
  }) {
    if (numberBytes == 1) {
      minimum = data[0] / division;
      maximum = data[1] / division;
      increment = data[2] / division;
    } else if (numberBytes == 2) {
      minimum = (data[0] + 256 * data[1]) / division;
      maximum = (data[2] + 256 * data[3]) / division;
      increment = (data[4] + 256 * data[5]) / division;
    }
  }
}
