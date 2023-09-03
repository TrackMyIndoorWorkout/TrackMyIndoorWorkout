class FitBaseType {
  final bool endianable;
  final int id;
  final String name;
  final int invalidValue;
  final int maxValue;
  final int size;

  const FitBaseType({
    required this.endianable,
    required this.id,
    required this.name,
    required this.invalidValue,
    required this.maxValue,
    required this.size,
  });
}

class FitBaseTypes {
  static const enumType = FitBaseType(
    endianable: false,
    id: 0x00,
    name: "enum",
    invalidValue: 0xFF,
    maxValue: 0xFE,
    size: 1,
  );
  static const sint8Type = FitBaseType(
    endianable: false,
    id: 0x01,
    name: "sint8",
    invalidValue: 0x7F,
    maxValue: 0x7E,
    size: 1,
  ); // 2’s complement format
  static const uint8Type = FitBaseType(
    endianable: false,
    id: 0x02,
    name: "uint8",
    invalidValue: 0xFF,
    maxValue: 0xFE,
    size: 1,
  );
  static const sint16Type = FitBaseType(
    endianable: true,
    id: 0x83,
    name: "sint16",
    invalidValue: 0x7FFF,
    maxValue: 0x7FFE,
    size: 2,
  ); // 2’s complement format
  static const uint16Type = FitBaseType(
    endianable: true,
    id: 0x84,
    name: "uint16",
    invalidValue: 0xFFFF,
    maxValue: 0xFFFE,
    size: 2,
  );
  static const sint32Type = FitBaseType(
    endianable: true,
    id: 0x85,
    name: "sint32",
    invalidValue: 0x7FFFFFFF,
    maxValue: 0x7FFFFFFE,
    size: 4,
  ); // 2’s complement format
  static const uint32Type = FitBaseType(
    endianable: true,
    id: 0x86,
    name: "uint32",
    invalidValue: 0xFFFFFFFF,
    maxValue: 0xFFFFFFFE,
    size: 4,
  );
  static const stringType = FitBaseType(
    endianable: false,
    id: 0x07,
    name: "string",
    invalidValue: 0x00,
    maxValue: 0xFE,
    size: 1,
  ); // Null terminated string encoded in UTF-8 format
  static const float32Type = FitBaseType(
    endianable: true,
    id: 0x88,
    name: "float32",
    invalidValue: 0xFFFFFFFF,
    maxValue: 0xFFFFFFFE,
    size: 4,
  );
  static const float64Type = FitBaseType(
    endianable: true,
    id: 0x89,
    name: "float64",
    invalidValue: 0xFFFFFFFFFFFFFFFF,
    maxValue: 0xFFFFFFFFFFFFFFFE,
    size: 8,
  );
  static const uint8zType = FitBaseType(
    endianable: false,
    id: 0x0A,
    name: "uint8z",
    invalidValue: 0x00,
    maxValue: 0xFE,
    size: 1,
  );
  static const uint16zType = FitBaseType(
    endianable: true,
    id: 0x8B,
    name: "uint16z",
    invalidValue: 0x0000,
    maxValue: 0xFFFE,
    size: 2,
  );
  static const uint32zType = FitBaseType(
    endianable: true,
    id: 0x8C,
    name: "uint32z",
    invalidValue: 0x00000000,
    maxValue: 0xFFFFFFFE,
    size: 4,
  );
  static const byteType = FitBaseType(
    endianable: false,
    id: 0x0D,
    name: "byte",
    invalidValue: 0xFF,
    maxValue: 0xFE,
    size: 1,
  ); // Array of bytes. Field is invalid if all bytes are invalid.
  static const sint64Type = FitBaseType(
    endianable: true,
    id: 0x8E,
    name: "sint64",
    invalidValue: 0x7FFFFFFFFFFFFFFF,
    maxValue: 0x7FFFFFFFFFFFFFFE,
    size: 8,
  ); // 2’s complement format
  static const uint64Type = FitBaseType(
    endianable: true,
    id: 0x8F,
    name: "uint64",
    invalidValue: 0xFFFFFFFFFFFFFFFF,
    maxValue: 0xFFFFFFFFFFFFFFFE,
    size: 8,
  );
  static const uint64zType = FitBaseType(
    endianable: true,
    id: 0x90,
    name: "uint64z",
    invalidValue: 0x0000000000000000,
    maxValue: 0xFFFFFFFFFFFFFFFE,
    size: 8,
  );
}
