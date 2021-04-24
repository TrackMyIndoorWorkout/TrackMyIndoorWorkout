import '../utils/constants.dart';
import '../utils/statistics_accumulator.dart';
import 'export_record.dart';

class ExportModel {
  String activityType;
  double totalDistance; // Total distance in meters
  double totalTime; // in seconds
  double averageSpeed; // in m/s
  double maximumSpeed; // in m/s
  int calories;
  int averageHeartRate;
  int maximumHeartRate;
  int averageCadence;
  int maximumCadence;
  double averagePower;
  double maximumPower;
  String intensity;
  DateTime dateActivity; // Date of the activity
  List<ExportRecord> records;

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
    ExportRecord lastRecord = records.last;
    if (lastRecord != null) {
      ExportRecord firstRecord = records.first;
      if ((totalTime == null || totalTime == 0) &&
          lastRecord.date != null &&
          firstRecord.date != null) {
        totalTime =
            (lastRecord.date.millisecondsSinceEpoch - firstRecord.date.millisecondsSinceEpoch) /
                1000;
      }

      if ((totalDistance == null || totalDistance == 0) && lastRecord.distance > 0) {
        totalDistance = lastRecord.distance;
      }
    }

    final calculateAvgSpeed = averageSpeed == null || averageSpeed == 0;
    final calculateMaxSpeed = maximumSpeed == null || maximumSpeed == 0;
    final calculateAvgHeartRate = averageHeartRate == null || averageHeartRate == 0;
    final calculateMaxHeartRate = maximumHeartRate == null || maximumHeartRate == 0;
    final calculateAvgCadence = averageCadence == null || averageCadence == 0;
    final calculateMaxCadence = maximumCadence == null || maximumCadence == 0;
    final calculateAvgPower = averagePower == null || averagePower == 0;
    final calculateMaxPower = maximumPower == null || maximumPower == 0;
    var accu = StatisticsAccumulator(
      si: true,
      sport: ActivityType.Ride,
      calculateAvgSpeed: calculateAvgSpeed,
      calculateMaxSpeed: calculateMaxSpeed,
      calculateAvgHeartRate: calculateAvgHeartRate,
      calculateMaxHeartRate: calculateMaxHeartRate,
      calculateAvgCadence: calculateAvgCadence,
      calculateMaxCadence: calculateMaxCadence,
      calculateAvgPower: calculateAvgPower,
      calculateMaxPower: calculateMaxPower,
    );

    if (calculateAvgSpeed ||
        calculateMaxSpeed ||
        calculateAvgHeartRate ||
        calculateMaxHeartRate ||
        calculateAvgCadence ||
        calculateMaxCadence ||
        calculateAvgPower ||
        calculateMaxPower) {
      records.forEach((trackPoint) {
        accu.processExportRecord(trackPoint);
      });
    }

    if (calculateAvgSpeed && accu.speedCount > 0) {
      averageSpeed = accu.avgSpeed;
    }

    if (calculateMaxSpeed && accu.maxSpeed > 0.0) {
      maximumSpeed = accu.maxSpeed;
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

    if (calculateMaxCadence && accu.maxCadence > 0) {
      maximumCadence = accu.maxCadence;
    }

    if (calculateAvgPower && accu.powerCount > 0) {
      averagePower = accu.avgPower;
    }

    if (calculateMaxPower && accu.maxPower > 0) {
      maximumPower = accu.maxPower;
    }
  }
}
