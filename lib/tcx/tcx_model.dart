class TCXModel {
  String activityType;
  double totalDistance; // Total distance in meters
  double totalTime; // in seconds
  double maxSpeed; // in m/s
  int calories;
  int averageHeartRate;
  int maximumHeartRate;
  int averageCadence;
  String intensity;
  DateTime dateActivity; // Date of the activity
  List<TrackPoint> points;

  // Related to device that generated the data
  String creator;
  String deviceName;
  String unitID;
  String productID;
  String versionMajor;
  String versionMinor;
  String buildMajor;
  String buildMinor;

  // Related to software used to generate the TCX file
  String author;
  String name;
  String swVersionMajor;
  String swVersionMinor;
  String buildVersionMajor;
  String buildVersionMinor;
  String langID;
  String partNumber;
}

class TrackPoint {
  double latitude; // in degrees
  double longitude;
  String timeStamp;
  double altitude; // in meters
  double speed; // Inst speed in m/s
  double distance; // in meters
  DateTime date;

  int cadence;
  double power;
  int heartRate;
}
