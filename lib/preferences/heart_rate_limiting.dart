import 'generic.dart';

const heartRateUpperLimit = "Heart Rate Upper Limit";
const heartRateUpperLimitTag = "heart_rate_upper_limit";
const heartRateUpperLimitIntTag = heartRateUpperLimitTag + intTagPostfix;
const heartRateUpperLimitMin = 0;
const heartRateUpperLimitDefault = 0;
const heartRateUpperLimitMax = 300;
const heartRateUpperLimitDescription = "This is a heart rate upper bound where the methods "
    "bellow would be applied. 0 means no upper limiting is performed.";

const heartRateLimitingMethod = "Heart Rate Limiting Method Selection:";
const heartRateLimitingMethodTag = "heart_rate_limiting_method";
const heartRateLimitingWriteZero = "write_zero";
const heartRateLimitingWriteZeroDescription = "Record zero when the heart rate limit is reached";
const heartRateLimitingWriteNothing = "write_nothing";
const heartRateLimitingWriteNothingDescription =
    "Don't record any heart rate when the limit is reached";
const heartRateLimitingCapAtLimit = "cap_at_limit";
const heartRateLimitingCapAtLimitDescription = "Cap the value at the level configured bellow";
const heartRateLimitingNoLimit = "no_limit";
const heartRateLimitingNoLimitDescription = "Don't apply any limiting";
const heartRateLimitingMethodDefault = heartRateLimitingNoLimit;
