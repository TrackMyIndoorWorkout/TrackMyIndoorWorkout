class Activity {
  static const TABLE_NAME = 'activities';
  static const ID = 'id';
  static const DEVICE_NAME = 'device_name';
  static const START = 'start';
  static const END = 'end';
  static const DISTANCE = 'distance';
  static const ELAPSED = 'elapsed';
  static const CALORIES = 'calories';
  static const AVG_POWER = 'avg_power';
  static const AVG_SPEED = 'avg_speed';
  static const AVG_CADENCE = 'avg_cadence';
  static const AVG_HEART_RATE = 'avg_heart_rate';

  int id;
  final String deviceName;
  final int start = DateTime.now().millisecondsSinceEpoch;
  int end;
  double distance;
  int elapsed;
  int calories;
  double avgPower;
  double avgSpeed;
  double avgCadence;
  double avgHeartRate;

  Activity(
      {this.id: 0,
      this.deviceName,
      this.distance: 0,
      this.elapsed: 0,
      this.calories: 0,
      this.avgPower: 0,
      this.avgSpeed: 0,
      this.avgCadence: 0,
      this.avgHeartRate: 0});

  update(double distance, int elapsed, int calories, double avgPower,
      double avgSpeed, double avgCadence, double avgHeartRate) {
    this.end = DateTime.now().millisecondsSinceEpoch;
    this.distance = distance;
    this.elapsed = elapsed;
    this.calories = calories;
    this.avgPower = avgPower;
    this.avgSpeed = avgSpeed;
    this.avgCadence = avgCadence;
    this.avgHeartRate = avgHeartRate;
  }

  Map<String, dynamic> toMap({bool forCreation: false}) {
    if (forCreation) {
      return {
        Activity.DEVICE_NAME: deviceName,
        Activity.START: start,
      };
    }
    return {
      Activity.END: end,
      Activity.DISTANCE: distance,
      Activity.ELAPSED: elapsed,
      Activity.CALORIES: calories,
      Activity.AVG_POWER: avgPower,
      Activity.AVG_SPEED: avgSpeed,
      Activity.AVG_CADENCE: avgCadence,
      Activity.AVG_HEART_RATE: avgHeartRate,
    };
  }
}
