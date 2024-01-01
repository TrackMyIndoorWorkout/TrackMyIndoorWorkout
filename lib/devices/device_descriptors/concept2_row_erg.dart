import '../device_fourcc.dart';
import 'concept2_erg.dart';

class Concept2RowErg extends Concept2Erg {
  Concept2RowErg()
      : super(
          deviceSportDescriptors[concept2RowerFourCC]!.defaultSport,
          deviceSportDescriptors[concept2RowerFourCC]!.isMultiSport,
          concept2RowerFourCC,
        );

  @override
  Concept2RowErg clone() => Concept2RowErg();
}
