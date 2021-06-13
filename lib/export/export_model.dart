import '../devices/device_descriptors/device_descriptor.dart';
import '../utils/constants.dart';
import '../utils/statistics_accumulator.dart';
import 'export_record.dart';

class ExportModel {
  String sport;
  double totalDistance = 0.0; // Total distance in meters
  double totalTime; // in seconds
  double averageSpeed = 0.0; // in m/s
  double maximumSpeed = 0.0; // in m/s
  int calories;
  int averageHeartRate = 0;
  int maximumHeartRate = 0;
  int averageCadence = 0;
  int maximumCadence = 0;
  double averagePower = 0.0;
  double maximumPower = 0.0;
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

    averageSpeed = accu.avgSpeed;
    maximumSpeed = accu.maxSpeed;
    averageHeartRate = accu.avgHeartRate;
    maximumHeartRate = accu.maxHeartRate;
    averageCadence = accu.avgCadence;
    maximumCadence = accu.maxCadence;
    averagePower = accu.avgPower;
    maximumPower = accu.maxPower;
  }
}
