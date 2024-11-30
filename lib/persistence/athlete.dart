import 'package:pref/pref.dart';

import '../preferences/athlete_age.dart';
import '../preferences/athlete_body_height.dart';
import '../preferences/athlete_body_weight.dart';
import '../preferences/athlete_email.dart';
import '../preferences/athlete_gender.dart';
import '../preferences/athlete_name.dart';
import '../preferences/athlete_vo2max.dart';
import '../preferences/unit_system.dart';

class Athlete {
  bool si;
  String firstName;
  String lastName;
  String email;
  int age;
  bool isMale;
  int weight; // kg
  int height; // cm
  int vo2Max;

  Athlete({
    this.si = false,
    this.firstName = athleteFirstNameDefault,
    this.lastName = athleteLastNameDefault,
    this.email = athleteEmailDefault,
    this.age = athleteAgeDefault,
    this.isMale = true,
    this.weight = athleteBodyWeightDefault,
    this.height = athleteBodyHeightDefault,
    this.vo2Max = athleteVO2MaxDefault,
  });

  static Athlete fromPreferences(BasePrefService prefService) {
    final storedSi = prefService.get<bool>(unitSystemTag) ?? unitSystemDefault;
    final firstName = prefService.get<String>(athleteFirstNameTag) ?? athleteFirstNameDefault;
    final lastName = prefService.get<String>(athleteLastNameTag) ?? athleteLastNameDefault;
    final email = prefService.get<String>(athleteEmailTag) ?? athleteEmailDefault;
    final storedAge = prefService.get<int>(athleteAgeTag) ?? athleteAgeDefault;
    final storedIsMale =
        (prefService.get<String>(athleteGenderTag) ?? athleteGenderDefault) == athleteGenderMale;
    final storedWeight = prefService.get<int>(athleteBodyWeightIntTag) ?? athleteBodyWeightDefault;
    final storedHeight = prefService.get<int>(athleteBodyHeightTag) ?? athleteBodyHeightDefault;
    final storedVo2Max = prefService.get<int>(athleteVO2MaxTag) ?? athleteVO2MaxDefault;
    return Athlete(
      si: storedSi,
      firstName: firstName,
      lastName: lastName,
      email: email,
      age: storedAge,
      isMale: storedIsMale,
      weight: storedWeight,
      height: storedHeight,
      vo2Max: storedVo2Max,
    );
  }

  @override
  String toString() {
    return "($firstName $lastName $email Age $age, isMale $isMale, "
        "Wt $weight, Ht $height, VO2Mx $vo2Max)";
  }
}
