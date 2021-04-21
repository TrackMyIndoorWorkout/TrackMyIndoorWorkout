import 'fit_record.dart';

class FitDataMessage extends FitRecord {
  List<int> data;

  FitDataMessage({localMessageType, globalMessageNumber})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: globalMessageNumber,
        ) {
    data = [];
  }

  List<int> binarySerialize() {
    super.binarySerialize();
    output.addAll(data);

    return output;
  }
}
