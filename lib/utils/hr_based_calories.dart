import '../preferences/athlete_vo2max.dart';

// Based on https://www.braydenwm.com/calburn.htm
double hrBasedCaloriesPerMinute(int heartRate, int weight, int age, bool isMale, int vo2Max) {
  if (vo2Max > athleteVO2MaxMin) {
    if (isMale) {
      return (-59.3954 +
              (-36.3781 + 0.271 * age + 0.394 * weight + 0.404 * vo2Max + 0.634 * heartRate)) /
          4.184;
    } else {
      return (-59.3954 + (0.274 * age + 0.103 * weight + 0.380 * vo2Max + 0.450 * heartRate)) /
          4.184;
    }
  } else {
    if (isMale) {
      return (-55.0969 + 0.6309 * heartRate + 0.1988 * weight + 0.2017 * age) / 4.184;
    } else {
      return (-20.4022 + 0.4472 * heartRate - 0.1263 * weight + 0.074 * age) / 4.184;
    }
  }
}
