const tpSandboxOAuthUrlBase = "https://oauth.sandbox.trainingpeaks.com/";
const tpProductionOAuthUrlBase = "https://oauth.trainingpeaks.com/";
const tpSandboxApiUrlBase = "https://api.sandbox.trainingpeaks.com/";
const tpProductionApiUrlBase = "https://api.trainingpeaks.com/";

const tokenPath = "oauth/token";
const authorizationPath = "OAuth/Authorize";
const deauthorizationPath = "oauth/deauthorize";
const uploadPath = "v1/file";

// To use with iOS or Android
const redirectUrlScheme = "trainingpeaksflutter";
const redirectUrl = "$redirectUrlScheme://redirect/";

const trainingPeaksAccessTokenTag = "trainingPeaks_accessToken";
const trainingPeaksRefreshTokenTag = "trainingPeaks_refreshToken";
const trainingPeaksExpiresAtTag = "trainingPeaks_expire";
const trainingPeaksTokenScopeTag = "trainingPeaks_scope";
