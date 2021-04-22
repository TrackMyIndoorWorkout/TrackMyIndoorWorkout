import '../utils/constants.dart';
import '../utils/statistics_accumulator.dart';
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

  process() {
    // Assuming that points are ordered by time stamp ascending
    ExportRecord lastRecord = points.last;
    if (lastRecord != null) {
      if ((totalTime == null || totalTime == 0) && lastRecord.date != null) {
        totalTime = lastRecord.date.millisecondsSinceEpoch / 1000;
      }
      if ((totalDistance == null || totalDistance == 0) && lastRecord.distance > 0) {
        totalDistance = lastRecord.distance;
      }
    }

    final calculateMaxSpeed = maxSpeed == null || maxSpeed == 0;
    final calculateAvgHeartRate = averageHeartRate == null || averageHeartRate == 0;
    final calculateMaxHeartRate = maximumHeartRate == null || maximumHeartRate == 0;
    final calculateAvgCadence = averageCadence == null || averageCadence == 0;
    var accu = StatisticsAccumulator(
      si: true,
      sport: ActivityType.Ride,
      calculateMaxSpeed: calculateMaxSpeed,
      calculateAvgHeartRate: calculateAvgHeartRate,
      calculateMaxHeartRate: calculateMaxHeartRate,
      calculateAvgCadence: calculateAvgCadence,
    );
    if (calculateMaxSpeed ||
        calculateAvgHeartRate ||
        calculateMaxHeartRate ||
        calculateAvgCadence) {
      points.forEach((trackPoint) {
        accu.processExportRecord(trackPoint);
      });
    }
    if (calculateMaxSpeed) {
      maxSpeed = accu.maxSpeed;
    }
    if (calculateAvgHeartRate && accu.heartRateCount > 0) {
      averageHeartRate = accu.avgHeartRate;
    }
    if (calculateMaxHeartRate && accu.maxHeartRate > 0) {
      maximumHeartRate = accu.maxHeartRate;
    }
    if (calculateAvgCadence && accu.cadenceCount > 0) {
      averageCadence = accu.avgCadence;
    }
  }
}
