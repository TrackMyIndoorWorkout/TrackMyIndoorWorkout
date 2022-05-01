const googleOAuthEndpoint = "https://accounts.google.com/o/oauth2/v2/auth";
const googleOAuthScope = "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ffitness.activity.write+"
    "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ffitness.heart_rate.write+"
    "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ffitness.location.write";
const googleTokenEndpoint = "https://www.googleapis.com/oauth2/v3/token";

// To use with iOS or Android
const redirectUrlScheme = "googlefitflutter";
const redirectUrl = "$redirectUrlScheme://redirect/";

const googleFitAccessTokenTag = "googleFit_accessToken";
const googleFitRefreshTokenTag = "googleFit_refreshToken";
const googleFitExpiresAtTag = "googleFit_expire";
const googleFitTokenScopeTag = "googleFit_scope";

const googleFitWebUrl = "https://www.google.com/fit/";
