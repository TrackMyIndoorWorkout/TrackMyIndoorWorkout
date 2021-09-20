import 'fit_record.dart';

class FitDataMessage extends FitRecord {
  List<int> data = [];

  FitDataMessage({required localMessageType, required globalMessageNumber})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: globalMessageNumber,
        );

  @override
  List<int> binarySerialize() {
    super.binarySerialize();
    output.addAll(data);

    return output;
  }
}
