const TP_SANDBOX_OAUTH_URL_BASE = "https://oauth.sandbox.trainingpeaks.com/";
const TP_PRODUCTION_OAUTH_URL_BASE = "https://oauth.trainingpeaks.com/";
const TP_SANDBOX_API_URL_BASE = "https://api.sandbox.trainingpeaks.com/";
const TP_PRODUCTION_API_URL_BASE = "https://api.trainingpeaks.com/";

const TOKEN_PATH = "oauth/token";
const AUTHORIZATION_PATH = "OAuth/Authorize";
const DEAUTHORIZATION_PATH = "oauth/deauthorize";
const UPLOAD_PATH = "v1/file";

// To use with iOS or Android
const REDIRECT_URL_SCHEME = "trainingpeaksflutter";
const REDIRECT_URL = "$REDIRECT_URL_SCHEME://redirect/";

const TRAINING_PEAKS_ACCESS_TOKEN_TAG = "trainingPeaks_accessToken";
const TRAINING_PEAKS_REFRESH_TOKEN_TAG = "trainingPeaks_refreshToken";
const TRAINING_PEAKS_EXPIRES_AT_TAG = "trainingPeaks_expire";
const TRAINING_PEAKS_TOKEN_SCOPE_TAG = "trainingPeaks_scope";
