import 'fit_record.dart';

class FitDataMessage extends FitRecord {
  List<int> data = [];

  FitDataMessage({required super.localMessageType, required super.globalMessageNumber});

  @override
  List<int> binarySerialize() {
    super.binarySerialize();
    output.addAll(data);

    return output;
  }
}
