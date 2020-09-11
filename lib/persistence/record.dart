class Record {
  static const TABLE_NAME = 'records';
  static const ID = 'id';
  static const ACTIVITY_ID = 'activity_id';
  static const TIME_STAMP = 'time_stamp';
  static const DISTANCE = 'distance';
  static const ELAPSED = 'elapsed';
  static const CALORIES = 'calories';
  static const POWER = 'power';
  static const SPEED = 'speed';
  static const CADENCE = 'cadence';
  static const HEART_RATE = 'heart_rate';
  static const LON = 'longitude';
  static const LAT = 'latitude';

  int id;
  final int activityId;
  final int timeStamp = DateTime.now().millisecondsSinceEpoch;
  final double distance;
  final int elapsed;
  final int calories;
  final int power;
  final double speed;
  final int cadence;
  final int heartRate;
  final double lon;
  final double lat;

  Record(
      {this.id: 0,
      this.activityId,
      this.distance,
      this.elapsed,
      this.calories,
      this.power,
      this.speed,
      this.cadence,
      this.heartRate,
      this.lon,
      this.lat});

  Map<String, dynamic> toMap({bool withId: false}) {
    Map<String, dynamic> map = {
      ID: id,
      ACTIVITY_ID: activityId,
      TIME_STAMP: timeStamp,
      DISTANCE: distance,
      ELAPSED: elapsed,
      CALORIES: calories,
      POWER: power,
      SPEED: speed,
      CADENCE: cadence,
      HEART_RATE: heartRate,
      LON: lon,
      LAT: lat
    };
    if (withId) {
      map[ID] = id;
    }
    return map;
  }
}
