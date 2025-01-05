class CadenceData {
  final double time;
  double revolutions;
  late DateTime timeStamp;

  CadenceData({required this.time, required this.revolutions}) {
    timeStamp = DateTime.now();
  }

  @override
  String toString() {
    return "($time, $revolutions, $timeStamp)";
  }
}
