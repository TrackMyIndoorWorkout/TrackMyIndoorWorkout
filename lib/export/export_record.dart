class ExportRecord {
  double latitude; // in degrees
  double longitude;
  String timeStampString;
  int timeStampInteger;
  double altitude; // in meters
  double speed; // Inst speed in m/s
  double distance; // in meters
  DateTime? date;

  int? cadence;
  double? power;
  int? heartRate;

  ExportRecord({
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.timeStampString = "0",
    this.timeStampInteger = 0,
    this.altitude = 0.0,
    this.speed = 0.0,
    this.distance = 0.0,
    this.date,
    this.cadence,
    this.power,
    this.heartRate,
  });
}
