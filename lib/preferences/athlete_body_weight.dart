import 'generic.dart';

const athleteBodyWeight = "Body Weight (kg)";
const athleteBodyWeightTag = "athlete_body_weight";
const athleteBodyWeightIntTag = athleteBodyWeightTag + intTagPostfix;
const athleteBodyWeightMin = 1;
const athleteBodyWeightDefault = 80;
const athleteBodyWeightMax = 300;
const athleteBodyWeightDivisions = athleteBodyWeightMax - athleteBodyWeightMin;
const athleteBodyWeightDescription =
    "This settings is optional. It could be used either for heart rate based calorie counting equations "
    "or spin-down capable devices to set "
    "the initial value displayed in the weight input until the device sends the last inputted weight. "
    "As soon as the last inputted weight is received from the device it'll override the value in the input";
