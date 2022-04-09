import '../../devices/device_descriptors/device_descriptor.dart';
import '../../ui/models/measurement_counter.dart';
import '../export_model.dart';
import 'json_aggregates.dart';

class JsonWorkout {
  JsonWorkout(
    this.startDatetime,
    this.name,
    this.aggregates,
    this.startLocaleTimezone,
    this.activityType,
  );

  String name;
  int activityType;
  DateTime startDatetime;
  String startLocaleTimezone;
  JsonAggregates aggregates;

  String timeSeries(ExportModel exportModel) {
    final measurementCounter = MeasurementCounter(si: true, sport: exportModel.activity.sport);
    for (var record in exportModel.records) {
      measurementCounter.processRecord(record.record);
    }

    final sb = StringBuffer();
    sb.write('"distance": [');
    sb.writeAll(
      exportModel.records.map((r) =>
          "[${r.elapsed(exportModel.activity)}, ${(r.record.distance ?? 0.0).toStringAsFixed(2)}]"),
      ",",
    );
    sb.write('],');
    sb.write('"speed": [');
    sb.writeAll(
      exportModel.records.map((r) =>
          "[${r.elapsed(exportModel.activity)}, ${((r.record.speed ?? 0.0) * DeviceDescriptor.kmh2ms).toStringAsFixed(2)}]"),
      ",",
    );
    sb.write('],');
    if (measurementCounter.hasPower) {
      sb.write('"power": [');
      sb.writeAll(
        exportModel.records.map((r) => "[${r.elapsed(exportModel.activity)}, ${r.record.power}]"),
        ",",
      );
      sb.write('],');
    }
    if (measurementCounter.hasCadence) {
      sb.write('"cadence": [');
      sb.writeAll(
        exportModel.records.map((r) => "[${r.elapsed(exportModel.activity)}, ${r.record.cadence}]"),
        ",",
      );
      sb.write('],');
    }
    if (measurementCounter.hasHeartRate) {
      sb.write('"heartrate": [');
      sb.writeAll(
        exportModel.records
            .map((r) => "[${r.elapsed(exportModel.activity)}, ${r.record.heartRate}]"),
        ",",
      );
      sb.write('],');
    }
    if (!exportModel.rawData && exportModel.calculateGps) {
      sb.write('"position": [');
      sb.writeAll(
        exportModel.records.map(
          (r) => '[${r.elapsed(exportModel.activity)}, {"lat": ${r.latitude.toStringAsFixed(7)}, '
              '"lng": ${r.longitude.toStringAsFixed(7)}, "elevation": ${exportModel.altitude}}]',
        ),
        ",",
      );
      sb.write(']');
    }
    return sb.toString();
  }

  String toJson(ExportModel exportModel) => '{"name": "$name",'
      '"activity_type": "/v7.1/activity_type/$activityType/",'
      '"start_datetime": "${startDatetime.toUtc().toIso8601String()}",'
      '"start_locale_timezone": "$startLocaleTimezone",'
      '"aggregates": ${aggregates.toJson()},'
      '"time_series": {${timeSeries(exportModel)}}}';
}
