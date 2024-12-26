import 'package:tuple/tuple.dart';

import 'constants.dart';

Tuple2<int, int> getWeightBytes(int weight, bool si) {
  final weightTransport = (weight * (si ? 1.0 : lbToKg) * 200).round();
  return Tuple2<int, int>(weightTransport % maxUint8, weightTransport ~/ maxUint8);
}

int getWeightFromBytes(int weightLsb, int weightMsb, bool si) {
  return (weightLsb + weightMsb * maxUint8) * (si ? 1.0 : kgToLb) ~/ 200;
}
