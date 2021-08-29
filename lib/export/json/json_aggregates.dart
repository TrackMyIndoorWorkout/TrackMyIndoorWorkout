class JsonAggregates {
  JsonAggregates(
    this.elapsedTimeTotal,
    this.distanceTotal,
    this.speedMin,
    this.speedMax,
    this.speedAvg,
    this.powerMin,
    this.powerMax,
    this.powerAvg,
    this.cadenceMin,
    this.cadenceMax,
    this.cadenceAvg,
    this.heartRateMin,
    this.heartRateMax,
    this.heartRateAvg,
  );

  int elapsedTimeTotal;
  double distanceTotal;
  double speedMin;
  double speedMax;
  double speedAvg;
  int powerMin;
  int powerMax;
  double powerAvg;
  int cadenceMin;
  int cadenceMax;
  int cadenceAvg;
  int heartRateMin;
  int heartRateMax;
  int heartRateAvg;

  String toJson() =>
      '{"elapsed_time_total": $elapsedTimeTotal,' +
      '"distance_total": $distanceTotal,' +
      '"speed_min": $speedMin,' +
      '"speed_max": $speedMax,' +
      '"speed_avg": $speedAvg,' +
      '"power_min": $powerMin,' +
      '"power_max": $powerMax,' +
      '"power_avg": $powerAvg,' +
      '"cadence_min": $cadenceMin,' +
      '"cadence_max": $cadenceMax,' +
      '"cadence_avg": $cadenceAvg,' +
      '"heartrate_min": $heartRateMin,' +
      '"heartrate_max": $heartRateMax,' +
      '"heartrate_avg": $heartRateAvg}';
}
