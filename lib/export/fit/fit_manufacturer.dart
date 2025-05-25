import 'package:edit_distance/edit_distance.dart';

import '../../devices/device_descriptors/matrix_treadmill_descriptor.dart';
import 'fit_base_type.dart';

const nautilusFitId = 14;
const suuntoFitId = 23;
const wahooFitnessFitId = 32;
const concept2FitId = 40;
const northPoleEngineeringFitId = 66;
const stagesCyclingFitId = 69;
const strydFitId = 95;
const technogymFitId = 111;
const johnsonHealthTechId = 122;
const polarElectroOyId = 123;
const precorFitId = 266;
const stravaFitId = 265;

Map<int, String> fitManufacturer = {
  1: 'garmin',
  2: 'garmin fr405 antfs', // Do not use. Used by FR405 for ANTFS man id.
  3: 'zephyr',
  4: 'dayton',
  5: 'idt',
  6: 'srm',
  7: 'quarq',
  8: 'ibike',
  9: 'saris',
  10: 'spark hk',
  11: 'tanita',
  12: 'echowell',
  13: 'dynastream oem',
  nautilusFitId: 'nautilus',
  15: 'dynastream',
  16: 'timex',
  17: 'metrigear',
  18: 'xelic',
  19: 'beurer',
  20: 'cardiosport',
  21: 'a and d',
  22: 'hmm',
  suuntoFitId: 'suunto',
  24: 'thita elektronik',
  25: 'gpulse',
  26: 'clean mobile',
  27: 'pedal brain',
  28: 'peaksware',
  29: 'saxonar',
  30: 'lemond fitness',
  31: 'dexcom',
  wahooFitnessFitId: 'wahoo fitness',
  33: 'octane fitness',
  34: 'archinoetics',
  35: 'the hurt box',
  36: 'citizen systems',
  37: 'magellan',
  38: 'osynce',
  39: 'holux',
  concept2FitId: 'concept2',
  42: 'one giant leap',
  43: 'ace sensor',
  44: 'brim brothers',
  45: 'xplova',
  46: 'perception digital',
  47: 'bf1systems',
  48: 'pioneer',
  49: 'spantec',
  50: 'metalogics',
  51: '4iiiis',
  52: 'seiko epson',
  53: 'seiko epson oem',
  54: 'ifor powell',
  55: 'maxwell guider',
  56: 'star trac',
  57: 'breakaway',
  58: 'alatech technology ltd',
  59: 'mio technology europe',
  60: 'rotor',
  61: 'geonaute',
  62: 'id bike',
  63: 'specialized',
  64: 'wtek',
  65: 'physical enterprises',
  northPoleEngineeringFitId: 'north pole engineering',
  67: 'bkool',
  68: 'cateye',
  69: 'stages cycling',
  70: 'sigmasport',
  71: 'tomtom',
  72: 'peripedal',
  73: 'wattbike',
  76: 'moxy',
  77: 'ciclosport',
  78: 'powerbahn',
  79: 'acorn projects aps',
  80: 'lifebeam',
  81: 'bontrager',
  82: 'wellgo',
  83: 'scosche',
  84: 'magura',
  85: 'woodway',
  86: 'elite',
  87: 'nielsen kellerman',
  88: 'dk city',
  89: 'tacx',
  90: 'direction technology',
  91: 'magtonic',
  92: '1partcarbon',
  93: 'inside ride technologies',
  94: 'sound of motion',
  strydFitId: 'stryd',
  96: 'icg', // Indoorcycling Group
  97: 'MiPulse',
  98: 'bsx athletics',
  99: 'look',
  100: 'campagnolo srl',
  101: 'body bike smart',
  102: 'praxisworks',
  103: 'limits technology', // Limits Technology Ltd.
  104: 'topaction technology', // TopAction Technology Inc.
  105: 'cosinuss',
  106: 'fitcare',
  107: 'magene',
  108: 'giant manufacturing co',
  109: 'tigrasport', // Tigrasport
  110: 'salutron',
  technogymFitId: 'technogym',
  112: 'bryton sensors',
  113: 'latitude limited',
  114: 'soaring technology',
  115: 'igpsport',
  116: 'thinkrider',
  117: 'gopher sport',
  118: 'waterrower',
  119: 'orangetheory',
  120: 'inpeak',
  121: 'kinetic',
  johnsonHealthTechId: 'johnson health tech',
  polarElectroOyId: 'polar electro',
  124: 'seesense',
  255: 'development',
  257: 'healthandlife',
  258: 'lezyne',
  259: 'scribe labs',
  260: 'zwift',
  261: 'watteam',
  262: 'recon',
  263: 'favero electronics',
  264: 'dynovelo',
  stravaFitId: 'strava',
  precorFitId: 'precor', // Amer Sports
  267: 'bryton',
  268: 'sram',
  269: 'navman', // MiTAC Global Corporation (Mio Technology)
  270: 'cobi', // COBI GmbH
  271: 'spivi',
  272: 'mio magellan',
  273: 'evesports',
  274: 'sensitivus gauge',
  275: 'podoon',
  276: 'life time fitness',
  277: 'falco e motors', // Falco eMotors Inc.
  278: 'minoura',
  279: 'cycliq',
  280: 'luxottica',
  281: 'trainer road',
  282: 'the sufferfest',
  283: 'fullspeedahead',
  284: 'virtualtraining',
  285: 'feedbacksports',
  286: 'omata',
  287: 'vdo',
  288: 'magneticdays',
  289: 'hammerhead',
  290: 'kinetic by kurt',
  291: 'shapelog',
  292: 'dabuziduo',
  293: 'jetblack',
  5759: 'actigraphcorp',
};

int getFitManufacturer(String manufacturer) {
  if (manufacturer.trim().isEmpty) {
    return FitBaseTypes.uint16Type.invalidValue;
  }

  final matrixDescriptor = MatrixTreadmillDescriptor();
  if (manufacturer.startsWith(matrixDescriptor.manufacturerNamePart)) {
    return johnsonHealthTechId;
  }

  var bestId = 0;
  var bestDistance = 1.0;
  JaroWinkler jaroWinkler = JaroWinkler();
  final manufacturerLower = manufacturer.toLowerCase();
  for (var manufacturerEntry in fitManufacturer.entries) {
    final manufacturerCropped = manufacturerLower.length <= manufacturerEntry.value.length
        ? manufacturerLower
        : manufacturerLower.substring(0, manufacturerEntry.value.length - 1);
    final entryCropped = manufacturerEntry.value.length <= manufacturerCropped.length
        ? manufacturerEntry.value
        : manufacturerEntry.value.substring(0, manufacturerCropped.length - 1);
    final distance = jaroWinkler.normalizedDistance(manufacturerCropped, entryCropped);
    if (distance < bestDistance) {
      bestDistance = distance;
      bestId = manufacturerEntry.key;
    }
  }

  if (bestDistance > 0.10) {
    bestId = stravaFitId;
  }

  return bestId;
}
