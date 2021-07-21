const EPS = 1e-6;
const DISPLAY_EPS = 1e-4;
const MIN_INIT = 10000;
const MAX_INIT = -10000;
const LB_TO_KG = 0.45359237;
const KG_TO_LB = 1 / LB_TO_KG;
const FT_TO_M = 0.3048;
const J_TO_CAL = 0.239006;
const J_TO_KCAL = J_TO_CAL / 1000.0;
const CAL_TO_J = 1 / J_TO_CAL;
const KM2MI = 0.621371;
const MI2KM = 1 / KM2MI;
const M2MILE = KM2MI / 1000.0;
const NOT_AVAILABLE = "N/A";
const EMPTY_MEASUREMENT = "--";
const HTTPS_PORT = 443;
const MAX_UINT8 = 256;
const MAX_BYTE = 255;
const MAX_UINT16 = 65536;
const MAX_UINT24 = MAX_UINT8 * MAX_UINT16;
const MAX_UINT32 = MAX_UINT16 * MAX_UINT16;
const DEG_TO_FIT_GPS = 11930464.711111111; // 2 ^ 32 / 360
const FONT_FAMILY = "RobotoMono";
const FONT_SIZE_FACTOR = 1.2;

class ActivityType {
  static const String AlpineSki = "AlpineSki";
  static const String BackcountrySki = "BackcountrySki";
  static const String Canoeing = "Canoeing";
  static const String Crossfit = "Crossfit";
  static const String EBikeRide = "EBikeRide";
  static const String Elliptical = "Elliptical";
  static const String Golf = "Golf";
  static const String Handcycle = "Handcycle";
  static const String Hike = "Hike";
  static const String IceSkate = "IceSkate";
  static const String InlineSkate = "InlineSkate";
  static const String Kayaking = "Kayaking";
  static const String Kitesurf = "Kitesurf";
  static const String NordicSki = "NordicSki";
  static const String Ride = "Ride";
  static const String RockClimbing = "RockClimbing";
  static const String RollerSki = "RollerSki";
  static const String Rowing = "Rowing";
  static const String Run = "Run";
  static const String Sail = "Sail";
  static const String Skateboard = "Skateboard";
  static const String Snowboard = "Snowboard";
  static const String Snowshoe = "Snowshoe";
  static const String Soccer = "Soccer";
  static const String StairStepper = "StairStepper";
  static const String StandUpPaddling = "StandUpPaddling";
  static const String Surfing = "Surfing";
  static const String Swim = "Swim";
  static const String Velomobile = "Velomobile";
  static const String VirtualRide = "VirtualRide";
  static const String VirtualRun = "VirtualRun";
  static const String Walk = "Walk";
  static const String WeightTraining = "WeightTraining";
  static const String Wheelchair = "Wheelchair";
  static const String Windsurf = "Windsurf";
  static const String Workout = "Workout";
  static const String Yoga = "Yoga";
}
