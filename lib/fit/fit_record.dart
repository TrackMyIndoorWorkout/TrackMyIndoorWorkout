import 'fit_field.dart';

class FitRecord {
  static const int LITTLE_ENDIAN = 0;
  static const int BIG_ENDIAN = 1;

  int header;
  final int reserved = 0;
  final int architecture = LITTLE_ENDIAN;
  int globalMessageNumber; // 2 bytes
  int numberOfFields;
  List<FitField> fields;
}
