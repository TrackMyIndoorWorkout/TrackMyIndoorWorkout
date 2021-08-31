const AU_API_URL_BASE = "https://api.ua.com/v7.1/";
const AU_URL_BASE = "https://www.mapmyfitness.com/v7.1/";
const AU_URL = AU_URL_BASE + "oauth2/uacf/";
const AU_API_URL = AU_API_URL_BASE + "oauth2/uacf/";
const TOKEN_ENDPOINT = AU_API_URL + "access_token";
const AUTHORIZATION_ENDPOINT = AU_URL + "authorize";
const UPLOADS_ENDPOINT = AU_URL_BASE + "workout/";

// To use with iOS or Android
const REDIRECT_URL_SCHEME = "mapmyfitnessflutter";
const REDIRECT_URL = "$REDIRECT_URL_SCHEME://redirect/";

const UNDER_ARMOUR_ACCESS_TOKEN_TAG = "underArmour_accessToken";
const UNDER_ARMOUR_REFRESH_TOKEN_TAG = "underArmour_refreshToken";
const UNDER_ARMOUR_EXPIRES_AT_TAG = "underArmour_expire";
const UNDER_ARMOUR_TOKEN_SCOPE_TAG = "underArmour_scope";
