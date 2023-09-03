const stravaUrl = "https://www.strava.com/";
const tokenEndpoint = "${stravaUrl}oauth/token";
const authorizationEndpoint = "${stravaUrl}oauth/authorize";
const deauthorizationEndpoint = "${stravaUrl}oauth/deauthorize";
const uploadsEndpoint = "${stravaUrl}api/v3/uploads";

// To use with iOS or Android
const redirectUrlScheme = "stravaflutter";
const redirectUrlMobile = "$redirectUrlScheme://redirect/";

const stravaAccessTokenTag = "strava_accessToken";
const stravaRefreshTokenTag = "strava_refreshToken";
const stravaExpiresAtTag = "strava_expire";
const stravaTokenScopeTag = "strava_scope";

const stravaActivityUrlBase = "https://www.strava.com/activities/";
