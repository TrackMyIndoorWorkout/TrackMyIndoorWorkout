/// To check if the activity has been uploaded successfully
/// No numeric error code for the moment given by Strava
class StravaStatusText {
  static const String ready = "Your activity is ready.";
  static const String deleted = "The created activity has been deleted.";
  static const String errorMsg = "There was an error processing your activity.";
  static const String processed = "Your activity is still being processed.";
  static const String notFound = 'Not Found';
}
