import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';

abstract class UploadService {
  Future<bool> login();

  Future<bool> hasValidToken();

  Future<int> upload(Activity activity, List<Record> records);
}
