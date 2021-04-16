import 'binary_serializable.dart';
import 'fit_field.dart';

class FitDefinitionMessage extends BinarySerializable {
  static const int LITTLE_ENDIAN = 0;
  static const int BIG_ENDIAN = 1;

  static const int MESSAGE_TYPE_DATA = 0;
  static const int MESSAGE_TYPE_DEFINITION = 1;

  int header;
  final int reserved = 0;
  final int architecture = LITTLE_ENDIAN;
  int localMessageType; // 3 bits
  int globalMessageNumber; // 2 bytes
  int numberOfFields;
  List<FitField> fields;

  List<int> binarySerialize() {
    // Assemble header from the architecture 
  }
}
