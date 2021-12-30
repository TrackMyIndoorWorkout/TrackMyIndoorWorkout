import 'generic.dart';

const athleteBodyWeight = "Body Weight (kg)";
const athleteBodyWeightTag = "athlete_body_weight";
const athleteBodyWeightIntTag = athleteBodyWeightTag + intTagPostfix;
const athleteBodyWeightMin = 1;
const athleteBodyWeightDefault = 60;
const athleteBodyWeightMax = 300;
const athleteBodyWeightDescription =
    "This settings is optional. It could be used either for heart rate based calorie counting equations "
    "or spin-down capable devices to set "
    "the initial value displayed in the weight input until the device sends the last inputted weight. "
    "As soon as the last inputted weight is received from the device it'll override the value in the input";

const rememberAthleteBodyWeight = "Remember last inputted weight at spin-down";
const rememberAthleteBodyWeightTag = "remember_athlete_body_weight";
const rememberAthleteBodyWeightDefault = true;
const rememberAthleteBodyWeightDescription =
    "On: The weight inputted at the beginning of a spin-down will override the weight above. "
    "Off: The weight input adjusted at spin-down won't be stored back to the setting above.";
