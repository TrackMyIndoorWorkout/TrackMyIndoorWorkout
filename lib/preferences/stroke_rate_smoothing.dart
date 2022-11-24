import 'generic.dart';

const strokeRateSmoothing = "Stroke Rate Smoothing";
const strokeRateSmoothingTag = "stroke_rate_smoothing";
const strokeRateSmoothingIntTag = strokeRateSmoothingTag + intTagPostfix;
const strokeRateSmoothingMin = 1;
const strokeRateSmoothingDefault = 10;
const strokeRateSmoothingMax = 50;
const strokeRateSmoothingDivisions = strokeRateSmoothingMax - strokeRateSmoothingMin;
const strokeRateSmoothingDescription = "Ergometers may provide too jittery data. Averaging "
    "these over time soothes the data. This setting tells the window size by how many samples "
    "could be in the smoothing queue. 1 means no smoothing.";
