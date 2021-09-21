// To use with iOS or Android
const REDIRECT_URL_SCHEME = "suuntoflutter";
const REDIRECT_URL = "$REDIRECT_URL_SCHEME://redirect/";

const OAUTH_API_URL = "https://cloudapi-oauth.suunto.com/oauth/";
const TOKEN_ENDPOINT = OAUTH_API_URL + "token";
const AUTHORIZATION_ENDPOINT = OAUTH_API_URL + "authorize";
const DEAUTHORIZATION_ENDPOINT = OAUTH_API_URL + "deauthorize";

const SUUNTO_API_URL = "https://cloudapi.suunto.com/v2/";
const UPLOADS_ENDPOINT = SUUNTO_API_URL + "upload";

const SUUNTO_ACCESS_TOKEN_TAG = "suunto_accessToken";
const SUUNTO_REFRESH_TOKEN_TAG = "suunto_refreshToken";
const SUUNTO_EXPIRES_AT_TAG = "suunto_expire";
