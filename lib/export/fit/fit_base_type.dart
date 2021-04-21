class FitBaseType {
  final bool endianable;
  final int id;
  final String name;
  final int invalidValue;
  final int size;

  const FitBaseType({this.endianable, this.id, this.name, this.invalidValue, this.size});
}

class FitBaseTypes {
  static const enumType = FitBaseType(
    endianable: false,
    id: 0x00,
    name: "enum",
    invalidValue: 0xFF,
    size: 1,
  );
  static const sint8Type = FitBaseType(
    endianable: false,
    id: 0x01,
    name: "sint8",
    invalidValue: 0x7F,
    size: 1,
  ); // 2’s complement format
  static const uint8Type = FitBaseType(
    endianable: false,
    id: 0x02,
    name: "uint8",
    invalidValue: 0xFF,
    size: 1,
  );
  static const sint16Type = FitBaseType(
    endianable: true,
    id: 0x83,
    name: "sint16",
    invalidValue: 0x7FFF,
    size: 2,
  ); // 2’s complement format
  static const uint16Type = FitBaseType(
    endianable: true,
    id: 0x84,
    name: "uint16",
    invalidValue: 0xFFFF,
    size: 2,
  );
  static const sint32Type = FitBaseType(
    endianable: true,
    id: 0x85,
    name: "sint32",
    invalidValue: 0x7FFFFFFF,
    size: 4,
  ); // 2’s complement format
  static const uint32Type = FitBaseType(
    endianable: true,
    id: 0x86,
    name: "uint32",
    invalidValue: 0xFFFFFFFF,
    size: 4,
  );
  static const stringType = FitBaseType(
    endianable: false,
    id: 0x07,
    name: "string",
    invalidValue: 0x00,
    size: 1,
  ); // Null terminated string encoded in UTF-8 format
  static const float32Type = FitBaseType(
    endianable: true,
    id: 0x88,
    name: "float32",
    invalidValue: 0xFFFFFFFF,
    size: 4,
  );
  static const float64Type = FitBaseType(
    endianable: true,
    id: 0x89,
    name: "float64",
    invalidValue: 0xFFFFFFFFFFFFFFFF,
    size: 8,
  );
  static const uint8zType = FitBaseType(
    endianable: false,
    id: 0x0A,
    name: "uint8z",
    invalidValue: 0x00,
    size: 1,
  );
  static const uint16zType = FitBaseType(
    endianable: true,
    id: 0x8B,
    name: "uint16z",
    invalidValue: 0x0000,
    size: 2,
  );
  static const uint32zType = FitBaseType(
    endianable: true,
    id: 0x8C,
    name: "uint32z",
    invalidValue: 0x00000000,
    size: 4,
  );
  static const byteType = FitBaseType(
    endianable: false,
    id: 0x0D,
    name: "byte",
    invalidValue: 0xFF,
    size: 1,
  ); // Array of bytes. Field is invalid if all bytes are invalid.
  static const sint64Type = FitBaseType(
    endianable: true,
    id: 0x8E,
    name: "sint64",
    invalidValue: 0x7FFFFFFFFFFFFFFF,
    size: 8,
  ); // 2’s complement format
  static const uint64Type = FitBaseType(
    endianable: true,
    id: 0x8F,
    name: "uint64",
    invalidValue: 0xFFFFFFFFFFFFFFFF,
    size: 8,
  );
  static const uint64zType = FitBaseType(
    endianable: true,
    id: 0x90,
    name: "uint64z",
    invalidValue: 0x0000000000000000,
    size: 8,
  );
}
