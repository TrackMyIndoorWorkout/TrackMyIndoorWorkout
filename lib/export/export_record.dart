import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';

class ExportRecord {
  Record record;
  double latitude; // in degrees
  double longitude;
  String timeStampString;
  int timeStampInteger;

  ExportRecord({
    required this.record,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.timeStampString = "0",
    this.timeStampInteger = 0,
  });
}
