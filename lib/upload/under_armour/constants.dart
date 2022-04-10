const auApiUrlBase = "https://api.ua.com/v7.1/";
const auUrlBase = "https://www.mapmyfitness.com/v7.1/";
const auUrl = auUrlBase + "oauth2/uacf/";
const auApiUrl = auApiUrlBase + "oauth2/uacf/";
const tokenEndpoint = auApiUrl + "access_token";
const authorizationEndpoint = auUrl + "authorize";
const uploadsEndpoint = auApiUrlBase + "workout/";

// To use with iOS or Android
const redirectUrlScheme = "mapmyfitnessflutter";
const redirectUrl = "$redirectUrlScheme://redirect/";

const underArmourAccessTokenTag = "underArmour_accessToken";
const underArmourRefreshTokenTag = "underArmour_refreshToken";
const underArmourExpiresAtTag = "underArmour_expire";
const underArmourTokenScopeTag = "underArmour_scope";

const underArmourWorkoutUrlBase = "https://www.mapmyrun.com/workout/";
