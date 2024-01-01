import '../device_fourcc.dart';
import 'concept2_erg.dart';

class Concept2BikeErg extends Concept2Erg {
  Concept2BikeErg()
      : super(
          deviceSportDescriptors[concept2BikeFourCC]!.defaultSport,
          deviceSportDescriptors[concept2BikeFourCC]!.isMultiSport,
          concept2BikeFourCC,
        );

  @override
  Concept2BikeErg clone() => Concept2BikeErg();
}
