import '../devices/device_descriptors/device_descriptor.dart';
import '../export/export_target.dart';
import '../persistence/activity.dart';
import '../utils/constants.dart';
import '../utils/statistics_accumulator.dart';
import 'export_record.dart';

class ExportModel {
  Activity activity;
  bool rawData;
  bool calculateGps;
  double averageSpeed = 0.0; // in m/s
  double maximumSpeed = 0.0; // in m/s
  double minimumSpeed = 0.0; // in m/s
  int averageHeartRate = 0;
  int maximumHeartRate = 0;
  int minimumHeartRate = 0;
  int averageCadence = 0;
  int maximumCadence = 0;
  int minimumCadence = 0;
  double averagePower = 0.0;
  int maximumPower = 0;
  int minimumPower = 0;
  double altitude = 0.0;
  List<ExportRecord> records;

  // Related to device that generated the data
  DeviceDescriptor descriptor;

  // Related to software used to generate the TCX file
  String author;
  String name;
  String swVersionMajor;
  String swVersionMinor;
  String buildVersionMajor;
  String buildVersionMinor;
  String langID;
  String partNumber;

  int exportTarget;

  ExportModel({
    required this.activity,
    required this.rawData,
    required this.calculateGps,
    required this.descriptor,
    required this.author,
    required this.name,
    required this.swVersionMajor,
    required this.swVersionMinor,
    required this.buildVersionMajor,
    required this.buildVersionMinor,
    required this.langID,
    required this.partNumber,
    required this.altitude,
    this.exportTarget = ExportTarget.regular,
    required this.records,
  }) {
    // Assuming that points are ordered by time stamp ascending
    if (records.isNotEmpty) {
      ExportRecord lastRecord = records.last;
      ExportRecord firstRecord = records.first;
      if (activity.elapsed == 0 &&
          lastRecord.record.timeStamp != null &&
          firstRecord.record.timeStamp != null) {
        activity.elapsed =
            lastRecord.record.timeStamp!.difference(firstRecord.record.timeStamp!).inSeconds;
      }

      if (activity.distance < eps && (lastRecord.record.distance ?? 0.0) > eps) {
        activity.distance = lastRecord.record.distance!;
      }
    }

    if (!rawData) {
      var accu = StatisticsAccumulator(
        si: true,
        sport: ActivityType.ride,
        calculateAvgSpeed: true,
        calculateMaxSpeed: true,
        calculateMinSpeed: true,
        calculateAvgHeartRate: true,
        calculateMaxHeartRate: true,
        calculateMinHeartRate: true,
        calculateAvgCadence: true,
        calculateMaxCadence: true,
        calculateMinCadence: true,
        calculateAvgPower: true,
        calculateMaxPower: true,
        calculateMinPower: true,
      );

      for (var trackPoint in records) {
        accu.processExportRecord(trackPoint);
      }

      averageSpeed = accu.avgSpeed;
      maximumSpeed = accu.maxSpeed;
      minimumSpeed = accu.minSpeed;
      averageHeartRate = accu.avgHeartRate;
      maximumHeartRate = accu.maxHeartRate;
      minimumHeartRate = accu.minHeartRate;
      averageCadence = accu.avgCadence;
      maximumCadence = accu.maxCadence;
      minimumCadence = accu.minCadence;
      averagePower = accu.avgPower;
      maximumPower = accu.maxPower;
      minimumPower = accu.minPower;
    }
  }
}
