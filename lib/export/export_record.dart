import '../persistence/floor/models/activity.dart';
import '../persistence/floor/models/record.dart';

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
