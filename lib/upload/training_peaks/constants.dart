const tpSandboxOAuthUrlBase = "https://oauth.sandbox.trainingpeaks.com/";
const tpProductionOAuthUrlBase = "https://oauth.trainingpeaks.com/";
const tpSandboxApiUrlBase = "https://api.sandbox.trainingpeaks.com/";
const tpProductionApiUrlBase = "https://api.trainingpeaks.com/";

const tokenPath = "oauth/token";
const authorizationPath = "OAuth/Authorize";
const deauthorizationPath = "oauth/deauthorize";
const uploadPath = "/v2/file/synchronous";

// To use with iOS or Android
const redirectUrlScheme = "trainingpeaksflutter";
const redirectUrl = "$redirectUrlScheme://redirect/";

const trainingPeaksAccessTokenTag = "trainingPeaks_accessToken";
const trainingPeaksRefreshTokenTag = "trainingPeaks_refreshToken";
const trainingPeaksExpiresAtTag = "trainingPeaks_expire";
const trainingPeaksTokenScopeTag = "trainingPeaks_scope";

const trainingPeaksPortalUrl = "https://app.trainingpeaks.com/";
