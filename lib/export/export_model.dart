import '../devices/device_descriptors/device_descriptor.dart';
import '../utils/constants.dart';
import '../utils/statistics_accumulator.dart';
import 'export_record.dart';

class ExportModel {
  String sport;
  double totalDistance; // Total distance in meters
  double totalTime; // in seconds
  late double averageSpeed; // in m/s
  late double maximumSpeed; // in m/s
  int calories;
  late int averageHeartRate;
  late int maximumHeartRate;
  late int averageCadence;
  late int maximumCadence;
  late double averagePower;
  late double maximumPower;
  DateTime dateActivity; // Date of the activity
  List<ExportRecord> records;

  // Related to device that generated the data
  DeviceDescriptor descriptor;
  String deviceId;
  int versionMajor;
  int versionMinor;
  int buildMajor;
  int buildMinor;

  // Related to software used to generate the TCX file
  String author;
  String name;
  int swVersionMajor;
  int swVersionMinor;
  int buildVersionMajor;
  int buildVersionMinor;
  String langID;
  String partNumber;

  ExportModel({
    required this.sport,
    required this.totalDistance,
    required this.totalTime,
    required this.calories,
    required this.dateActivity,
    required this.descriptor,
    required this.deviceId,
    required this.versionMajor,
    required this.versionMinor,
    required this.buildMajor,
    required this.buildMinor,
    required this.author,
    required this.name,
    required this.swVersionMajor,
    required this.swVersionMinor,
    required this.buildVersionMajor,
    required this.buildVersionMinor,
    required this.langID,
    required this.partNumber,
    required this.records,
  }) {
    // Assuming that points are ordered by time stamp ascending
    if (records.length > 0) {
      ExportRecord lastRecord = records.last;
      ExportRecord firstRecord = records.first;
      if (totalTime == 0 && lastRecord.date != null && firstRecord.date != null) {
        totalTime =
            (lastRecord.date!.millisecondsSinceEpoch - firstRecord.date!.millisecondsSinceEpoch) /
                1000;
      }

      if (totalDistance < EPS && lastRecord.distance > EPS) {
        totalDistance = lastRecord.distance;
      }
    }

    var accu = StatisticsAccumulator(
      si: true,
      sport: ActivityType.Ride,
      calculateAvgSpeed: true,
      calculateMaxSpeed: true,
      calculateAvgHeartRate: true,
      calculateMaxHeartRate: true,
      calculateAvgCadence: true,
      calculateMaxCadence: true,
      calculateAvgPower: true,
      calculateMaxPower: true,
    );

    records.forEach((trackPoint) {
      accu.processExportRecord(trackPoint);
    });

    if (accu.speedCount > 0) {
      averageSpeed = accu.avgSpeed;
    }

    if (accu.maxSpeed > 0.0) {
      maximumSpeed = accu.maxSpeed;
    }

    if (accu.heartRateCount > 0) {
      averageHeartRate = accu.avgHeartRate;
    }

    if (accu.maxHeartRate > 0) {
      maximumHeartRate = accu.maxHeartRate;
    }

    if (accu.cadenceCount > 0) {
      averageCadence = accu.avgCadence;
    }

    if (accu.maxCadence > 0) {
      maximumCadence = accu.maxCadence;
    }

    if (accu.powerCount > 0) {
      averagePower = accu.avgPower;
    }

    if (accu.maxPower > 0) {
      maximumPower = accu.maxPower;
    }
  }
}
