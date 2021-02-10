import 'package:meta/meta.dart';

class FontFamilyProperties {
  final String primary;
  final String secondary;

  FontFamilyProperties({
    @required this.primary,
    @required this.secondary,
  })  : assert(primary != null),
        assert(secondary != null);
}
