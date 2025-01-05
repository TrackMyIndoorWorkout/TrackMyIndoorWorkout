import '../device_fourcc.dart';
import 'concept2_erg.dart';

class Concept2SkiErg extends Concept2Erg {
  Concept2SkiErg()
      : super(
          deviceSportDescriptors[concept2SkiFourCC]!.defaultSport,
          deviceSportDescriptors[concept2SkiFourCC]!.isMultiSport,
          concept2SkiFourCC,
        );

  @override
  Concept2SkiErg clone() => Concept2SkiErg();
}
