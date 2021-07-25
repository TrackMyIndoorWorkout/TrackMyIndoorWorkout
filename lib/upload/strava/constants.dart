const STRAVA_URL = "https://www.strava.com/";
const TOKEN_ENDPOINT = STRAVA_URL + "oauth/token";
const AUTHORIZATION_ENDPOINT = STRAVA_URL + "oauth/authorize";
const DEAUTHORIZATION_ENDPOINT = STRAVA_URL + "oauth/deauthorize";
const UPLOADS_ENDPOINT = STRAVA_URL + "api/v3/uploads";

const REDIRECT_URL_WEB = "https://trackmyindoorworkout.github.io";

// To use with iOS or Android
const REDIRECT_URL_SCHEME = "stravaflutter";
const REDIRECT_URL_MOBILE = "$REDIRECT_URL_SCHEME://redirect/";

const ACCESS_TOKEN_TAG = "strava_accessToken";
const REFRESH_TOKEN_TAG = "strava_refreshToken";
const EXPIRES_AT_TAG = "strava_expire";
const TOKEN_SCOPE_TAG = "strava_scope";
