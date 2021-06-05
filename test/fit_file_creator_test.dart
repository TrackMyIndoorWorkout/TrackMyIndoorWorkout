import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_file_creator.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';

void main() {
  test('FitFileCreator has the expected global message number', () async {
    final fileCreator = FitFileCreator(0);

    expect(fileCreator.globalMessageNumber, FitMessage.FileCreator);
  });

  test('FitFileCreator data has the expected length', () async {
    final fileCreator = FitFileCreator(0);
    final output = fileCreator.serializeData(null);
    final expected = fileCreator.fields.fold<int>(0, (accu, field) => accu + field.size);

    expect(output.length, expected + 1);
  });
}
