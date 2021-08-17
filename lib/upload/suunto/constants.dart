// To use with iOS or Android
import '../../persistence/secret.dart';

const REDIRECT_URL_SCHEME = "suuntoflutter";
const REDIRECT_URL_MOBILE = "$REDIRECT_URL_SCHEME://redirect/";

const OAUTH_API_HOST = "https://cloudapi-oauth.suunto.com/oauth/";
const AUTHORIZATION_URL = "$OAUTH_API_HOST/authorize?response_type=code&client_id=$SUUNTO_CLIENT_ID&redirect_uri=$REDIRECT_URL_MOBILE";

const SUUNTO_ACCESS_TOKEN_TAG = "suunto_accessToken";
const SUUNTO_REFRESH_TOKEN_TAG = "suunto_refreshToken";
const SUUNTO_EXPIRES_AT_TAG = "suunto_expire";
