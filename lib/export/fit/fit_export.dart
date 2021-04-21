import '../activity_export.dart';
import '../export_model.dart';
import 'fit_header.dart';
import 'fit_serializable.dart';

class FitExport extends ActivityExport {
  static String nonCompressedFileExtension = 'fit';
  static String compressedFileExtension = nonCompressedFileExtension + '.gz';
  static String nonCompressedMimeType = 'application/octet-stream';
  static String compressedMimeType = 'application/x-gzip';

  List<int> _bytes;

  FitExport() : super() {
    _bytes = [];
  }

  Future<List<int>> getFileCore(ExportModel tcxInfo) async {
    final header = FitHeader();
    _bytes.addAll(header.binarySerialize());
    return _bytes;
  }

  String timeStampString(DateTime dateTime) {
    return ""; // Not used for FIT
  }

  int timeStampInteger(DateTime dateTime) {
    return FitSerializable.fitDateTime(dateTime);
  }
}
