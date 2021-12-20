// To use with iOS or Android
const redirectUrlScheme = "suuntoflutter";
const redirectUrl = "$redirectUrlScheme://redirect/";

const oauthApiUrl = "https://cloudapi-oauth.suunto.com/oauth/";
const tokenEndpoint = oauthApiUrl + "token";
const authorizationEndpoint = oauthApiUrl + "authorize";
const deauthorizationEndpoint = oauthApiUrl + "deauthorize";

const suuntoApiUrl = "https://cloudapi.suunto.com/v2/";
const uploadsEndpoint = suuntoApiUrl + "upload";

const suuntoAccessTokenTag = "suunto_accessToken";
const suuntoRefreshTokenTag = "suunto_refreshToken";
const suuntoExpiresAtTag = "suunto_expire";
