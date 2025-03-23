import 'package:tuple/tuple.dart';

const kayakFirstDisplay = "Kayak First Display Config.:";
const kayakFirstDisplayDescription =
    "Choices: "
    "0. Elapsed time, 2. Total distance (*), "
    "3. Avg. speed (*), 4. Inst. speed, "
    "5. Avg. stroke rate, 6. Inst. stroke rate, "
    "7. Avg. 200m pace (sec), 8. Inst. 200m pace (sec), "
    "9. Avg. 500m pace (sec), 10. Inst. 500m pace (sec), "
    "11. Avg. 1000m pace (sec), 12. Inst. 1000m pace (sec), "
    "13. Avg. force, 14. Inst. force, "
    "15. Total Expended Energy (*) (kCal), "
    "17. Inst. power (W), 18. Avg. power (W). * = since reset";

const displayChoiceElapsedTime = 0;
const displayChoiceElapsedTimeDescription = "Elapsed Time";
const displayChoiceTotalDistance = 2;
const displayChoiceTotalDistanceDescription = "Total Distance";
const displayChoiceAverageSpeed = 3;
const displayChoiceAverageSpeedDescription = "Average Speed";
const displayChoiceInstantaneousSpeed = 4;
const displayChoiceInstantaneousSpeedDescription = "Instantaneous Speed";
const displayChoiceAverageStrokeRate = 5;
const displayChoiceAverageStrokeRateDescription = "Average Stroke Rate";
const displayChoiceInstantaneousStrokeRate = 6;
const displayChoiceInstantaneousStrokeRateDescription = "Inst. Stroke Rate";
const displayChoiceAverage200mPace = 7;
const displayChoiceAverage200mPaceDescription = "Average 200m Pace (sec)";
const displayChoiceInstantaneous200mPace = 8;
const displayChoiceInstantaneous200mPaceDescription = "Inst. 200m Pace (sec)";
const displayChoiceAverage500mPace = 9;
const displayChoiceAverage500mPaceDescription = "Average 500m Pace (sec)";
const displayChoiceInstantaneous500mPace = 10;
const displayChoiceInstantaneous500mPaceDescription = "Inst. 500m Pace (sec)";
const displayChoiceAverage1000mPace = 11;
const displayChoiceAverage1000mPaceDescription = "Average 1000m Pace (sec)";
const displayChoiceInstantaneous1000mPace = 12;
const displayChoiceInstantaneous1000mPaceDescription = "Inst. 1000m Pace (sec)";
const displayChoiceAverageForce = 13;
const displayChoiceAverageForceDescription = "Average Force";
const displayChoiceInstantaneousForce = 14;
const displayChoiceInstantaneousForceDescription = "Instantaneous Force";
const displayChoiceTotalExpendedEnergy = 15;
const displayChoiceTotalExpendedEnergyDescription = "Total Expended Energy";
const displayChoiceInstantaneousPower = 17;
const displayChoiceInstantaneousPowerDescription = "Instantaneous Power";
const displayChoiceAveragePower = 18;
const displayChoiceAveragePowerDescription = "Average Power";

const List<Tuple2<int, String>> kayakFirstDisplayChoices = [
  Tuple2(displayChoiceElapsedTime, displayChoiceElapsedTimeDescription),
  Tuple2(displayChoiceTotalDistance, displayChoiceTotalDistanceDescription),
  Tuple2(displayChoiceAverageSpeed, displayChoiceAverageSpeedDescription),
  Tuple2(displayChoiceInstantaneousSpeed, displayChoiceInstantaneousSpeedDescription),
  Tuple2(displayChoiceAverageStrokeRate, displayChoiceAverageStrokeRateDescription),
  Tuple2(displayChoiceInstantaneousStrokeRate, displayChoiceInstantaneousStrokeRateDescription),
  Tuple2(displayChoiceAverage200mPace, displayChoiceAverage200mPaceDescription),
  Tuple2(displayChoiceInstantaneous200mPace, displayChoiceInstantaneous200mPaceDescription),
  Tuple2(displayChoiceAverage500mPace, displayChoiceAverage500mPaceDescription),
  Tuple2(displayChoiceInstantaneous500mPace, displayChoiceInstantaneous500mPaceDescription),
  Tuple2(displayChoiceAverage1000mPace, displayChoiceAverage1000mPaceDescription),
  Tuple2(displayChoiceInstantaneous1000mPace, displayChoiceInstantaneous1000mPaceDescription),
  Tuple2(displayChoiceAverageForce, displayChoiceAverageForceDescription),
  Tuple2(displayChoiceInstantaneousForce, displayChoiceInstantaneousForceDescription),
  Tuple2(displayChoiceTotalExpendedEnergy, displayChoiceTotalExpendedEnergyDescription),
  Tuple2(displayChoiceInstantaneousPower, displayChoiceInstantaneousPowerDescription),
  Tuple2(displayChoiceAveragePower, displayChoiceAveragePowerDescription),
];

// Default: 0;2;5;11;15
// Documentation example: 14;10;4;2;6
const kayakFirstDisplaySlot1 = "Slot 1:";
const kayakFirstDisplaySlot1Tag = "kayak_first_display_slot_1";
const kayakFirstDisplaySlot1Description = "(1st Slot of the KayakFirst Disp. Conf.)";
const kayakFirstDisplaySlot1Default = displayChoiceElapsedTime;
const kayakFirstDisplaySlot2 = "Slot 2:";
const kayakFirstDisplaySlot2Tag = "kayak_first_display_slot_2";
const kayakFirstDisplaySlot2Description = "(2nd Slot of the KayakFirst Disp. Conf.)";
const kayakFirstDisplaySlot2Default = displayChoiceTotalDistance;
const kayakFirstDisplaySlot3 = "Slot 3:";
const kayakFirstDisplaySlot3Tag = "kayak_first_display_slot_3";
const kayakFirstDisplaySlot3Description = "(3rd Slot of the KayakFirst Disp. Conf.)";
const kayakFirstDisplaySlot3Default = displayChoiceAverageStrokeRate;
const kayakFirstDisplaySlot4 = "Slot 4:";
const kayakFirstDisplaySlot4Tag = "kayak_first_display_slot_4";
const kayakFirstDisplaySlot4Description = "(4th Slot of the KayakFirst Disp. Conf.)";
const kayakFirstDisplaySlot4Default = displayChoiceAverage1000mPace;
const kayakFirstDisplaySlot5 = "Slot 5:";
const kayakFirstDisplaySlot5Tag = "kayak_first_display_slot_5";
const kayakFirstDisplaySlot5Description = "(5th Slot of the KayakFirst Disp. Conf.)";
const kayakFirstDisplaySlot5Default = displayChoiceTotalExpendedEnergy;

const List<Tuple4<String, String, String, int>> kayakFirstDisplaySlots = [
  Tuple4(
    kayakFirstDisplaySlot1,
    kayakFirstDisplaySlot1Tag,
    kayakFirstDisplaySlot1Description,
    kayakFirstDisplaySlot1Default,
  ),
  Tuple4(
    kayakFirstDisplaySlot2,
    kayakFirstDisplaySlot2Tag,
    kayakFirstDisplaySlot2Description,
    kayakFirstDisplaySlot2Default,
  ),
  Tuple4(
    kayakFirstDisplaySlot3,
    kayakFirstDisplaySlot3Tag,
    kayakFirstDisplaySlot3Description,
    kayakFirstDisplaySlot3Default,
  ),
  Tuple4(
    kayakFirstDisplaySlot4,
    kayakFirstDisplaySlot4Tag,
    kayakFirstDisplaySlot4Description,
    kayakFirstDisplaySlot4Default,
  ),
  Tuple4(
    kayakFirstDisplaySlot5,
    kayakFirstDisplaySlot5Tag,
    kayakFirstDisplaySlot5Description,
    kayakFirstDisplaySlot5Default,
  ),
];
