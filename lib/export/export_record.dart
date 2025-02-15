import '../persistence/activity.dart';
import '../persistence/record.dart';

class ExportRecord {
  Record record;
  double latitude; // in degrees
  double longitude;

  ExportRecord({required this.record, this.latitude = 0.0, this.longitude = 0.0});

  double elapsed(Activity activity) {
    return (record.timeStamp ?? DateTime.now()).difference(activity.start).inMilliseconds / 1000;
  }
}
