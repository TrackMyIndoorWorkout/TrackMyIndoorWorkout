const testing = bool.fromEnvironment('testing_mode', defaultValue: false);

const eps = 1e-6;
const displayEps = 1e-4;
const minInit = 10000;
const maxInit = -10000;
const lbToKg = 0.45359237;
const kgToLb = 1 / lbToKg;
const ftToM = 0.3048;
const jToCal = 0.239006;
const jToKCal = jToCal / 1000.0;
const calToJ = 1 / jToCal;
const km2mi = 0.621371;
const mi2km = 1 / km2mi;
const m2mile = km2mi / 1000.0;
const m2yard = 1.09361;
const thousandYardsInMeters = 1000.0 / m2yard;
const notAvailable = "N/A";
const emptyMeasurement = "--";
const httpsPort = 443;
const maxUint8 = 256;
const maxByte = 255;
const maxUint16 = 65536;
const maxUint24 = maxUint8 * maxUint16;
const maxUint32 = maxUint16 * maxUint16;
const maxUint48 = maxUint24 * maxUint24;
const degToFitGps = 11930464.711111111; // 2 ^ 32 / 360
const fontFamily = "RobotoMono";
const fontSizeFactor = 1.2;
const appName = "Track My Indoor Exercise";

class ActivityType {
  static const String alpineSki = "AlpineSki";
  static const String backcountrySki = "BackcountrySki";
  static const String canoeing = "Canoeing";
  static const String crossfit = "Crossfit";
  static const String eBikeRide = "EBikeRide";
  static const String elliptical = "Elliptical";
  static const String golf = "Golf";
  static const String handcycle = "Handcycle";
  static const String hike = "Hike";
  static const String iceSkate = "IceSkate";
  static const String inlineSkate = "InlineSkate";
  static const String kayaking = "Kayaking";
  static const String kitesurf = "Kitesurf";
  static const String nordicSki = "NordicSki";
  static const String ride = "Ride";
  static const String rockClimbing = "RockClimbing";
  static const String rollerSki = "RollerSki";
  static const String rowing = "Rowing";
  static const String run = "Run";
  static const String sail = "Sail";
  static const String skateboard = "Skateboard";
  static const String snowboard = "Snowboard";
  static const String snowshoe = "Snowshoe";
  static const String soccer = "Soccer";
  static const String stairStepper = "StairStepper";
  static const String standUpPaddling = "StandUpPaddling";
  static const String surfing = "Surfing";
  static const String swim = "Swim";
  static const String velomobile = "Velomobile";
  static const String virtualRide = "VirtualRide";
  static const String virtualRun = "VirtualRun";
  static const String walk = "Walk";
  static const String weightTraining = "WeightTraining";
  static const String wheelchair = "Wheelchair";
  static const String windsurf = "Windsurf";
  static const String workout = "Workout";
  static const String yoga = "Yoga";
}

const waterSports = [
  ActivityType.kayaking,
  ActivityType.canoeing,
  ActivityType.rowing,
  ActivityType.swim,
];

const allSports = [
  ActivityType.ride,
  ActivityType.run,
  ActivityType.elliptical,
  ActivityType.kayaking,
  ActivityType.canoeing,
  ActivityType.rowing,
  ActivityType.swim,
];
