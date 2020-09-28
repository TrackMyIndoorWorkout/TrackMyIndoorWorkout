class PreferencesSpec {
  final String metric;
  final String title;
  final String thresholdTag;
  final String thresholdDefault;
  final String zonesTag;
  final String zonesDefault;

  PreferencesSpec({
    this.metric,
    this.title,
    this.thresholdTag,
    this.thresholdDefault,
    this.zonesTag,
    this.zonesDefault,
  });
}

const THRESHOLD_CAPITAL = 'Threshold ';
const ZONES_CAPITAL = ' Zones';
const THRESHOLD_PREFIX = 'threshold_';
const ZONES_POSTFIX = '_zones';
const METRICS = ['power', 'speed', 'cadence', 'hr'];

final preferencesSpecs = [
  PreferencesSpec(
    metric: METRICS[0],
    title: 'Power',
    thresholdTag: THRESHOLD_PREFIX + METRICS[0],
    thresholdDefault: '360',
    zonesTag: METRICS[0] + ZONES_POSTFIX,
    zonesDefault: '55,75,90,105,120,150',
  ),
  PreferencesSpec(
    metric: METRICS[1],
    title: 'Speed',
    thresholdTag: THRESHOLD_PREFIX + METRICS[1],
    thresholdDefault: '30',
    zonesTag: METRICS[1] + ZONES_POSTFIX,
    zonesDefault: '55,75,90,105,120,150',
  ),
  PreferencesSpec(
    metric: METRICS[2],
    title: 'Cadence',
    thresholdTag: THRESHOLD_PREFIX + METRICS[2],
    thresholdDefault: '120',
    zonesTag: METRICS[2] + ZONES_POSTFIX,
    zonesDefault: '25,37,50,75,100,120',
  ),
  PreferencesSpec(
    metric: METRICS[3],
    title: 'Heart Rate',
    thresholdTag: THRESHOLD_PREFIX + METRICS[3],
    thresholdDefault: '180',
    zonesTag: METRICS[3] + ZONES_POSTFIX,
    zonesDefault: '50,60,70,80,90,100',
  ),
];
