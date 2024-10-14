const uaApiUrlBase = "https://api.mapmyfitness.com/v7.1/";
const uaUrlBase = "https://www.mapmyfitness.com/v7.1/";
const uaUrl = "${uaUrlBase}oauth2/uacf/";
const uaApiUrl = "${uaApiUrlBase}oauth2/uacf/";
const tokenEndpoint = "${uaApiUrl}access_token";
const authorizationEndpoint = "${uaUrl}authorize";
const uploadsEndpoint = "${uaApiUrlBase}workout/";

// To use with iOS or Android
const redirectUrlScheme = "mapmyfitnessflutter";
const redirectUrl = "$redirectUrlScheme://redirect/";

const underArmourAccessTokenTag = "underArmour_accessToken";
const underArmourRefreshTokenTag = "underArmour_refreshToken";
const underArmourExpiresAtTag = "underArmour_expire";
const underArmourTokenScopeTag = "underArmour_scope";

const underArmourWorkoutUrlBase = "https://www.mapmyfitness.com/workout/";
