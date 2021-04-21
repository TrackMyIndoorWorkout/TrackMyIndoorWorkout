import 'export_record.dart';

class ExportModel {
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
  List<ExportRecord> points;

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
