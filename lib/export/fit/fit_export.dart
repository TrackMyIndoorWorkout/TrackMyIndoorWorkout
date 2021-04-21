import '../activity_export.dart';
import '../export_model.dart';

class FitExport extends ActivityExport {
  static String nonCompressedFileExtension = 'fit';
  static String compressedFileExtension = nonCompressedFileExtension + '.gz';
  static String nonCompressedMimeType = 'application/octet-stream';
  static String compressedMimeType = 'application/x-gzip';

  List<int> _bytes;

  FitExport(): super() {
    _bytes = [];
  }

  Future<List<int>> getFileCore(ExportModel tcxInfo) async {
    return [];
  }

  static String createTimestamp(DateTime dateTime) {
    return dateTime.toUtc().toString().replaceFirst(' ', 'T');
  }

  String timeStampString(DateTime dateTime) {
    return ""; // Not used for FIT
  }

  int timeStampInteger(DateTime dateTime) {
    return 0;  // TODO
  }
}
