import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';

class ExportRecord {
  Record record;
  double latitude; // in degrees
  double longitude;

  ExportRecord({
    required this.record,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  double elapsed(Activity activity) {
    return ((record.timeStamp ?? 0) - activity.start) / 1000;
  }
}
