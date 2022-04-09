const leaderboardFeature = "Leaderboard Feature";
const leaderboardFeatureTag = "leaderboard_feature";
const leaderboardFeatureDefault = false;
const leaderboardFeatureDescription =
    "Leaderboard registry: should the app record workout entries for leaderboard purposes.";

const rankRibbonVisualization = "Display Rank Ribbons Above the Speed Graph";
const rankRibbonVisualizationTag = "rank_ribbon_visualization";
const rankRibbonVisualizationDefault = false;
const rankRibbonVisualizationDescription =
    "Should the app provide UI feedback by ribbons above the speed graph. "
    "Blue color means behind the top leaderboard, green marks record pace.";

// Obsolete, converted to exclusive rankingForSportOrDevice
const rankingForDeviceOldTag = "ranking_for_device";
const rankingForDeviceOldDefault = false;
const rankingForSportOldTag = "ranking_for_sport";
const rankingForSportOldDefault = false;

const rankingForSportOrDevice = "Rank For Sport or Device";
const rankingForSportOrDeviceTag = "ranking_for_sport_or_device";
const rankingForSportOrDeviceDefault = true;
const rankingForSportOrDeviceDescription = "On: Ranking based on all devices for the sport. "
    "Off: Ranking based on the particular machine only. "
    "This affects both the ribbon type and the track visualization.";

const rankTrackVisualization = "Visualize Rank Positions on the Track";
const rankTrackVisualizationTag = "rank_track_visualization";
const rankTrackVisualizationDefault = false;
const rankTrackVisualizationDescription =
    "For performance reasons only the position right ahead (green color) and right behind "
    "(blue color) of the current effort is displayed. Both positions have a the rank "
    "number inside their dot.";

const rankInfoOnTrack = "Display rank information at the center of the track (on top of positions)";
const rankInfoOnTrackTag = "rank_info_on_track";
const rankInfoOnTrackDefault = true;
const rankInfoOnTrackDescription =
    "On: when rank position is enabled this switch will display extra information "
    "in the middle of the track: it'll list the preceding and following positions "
    "along with the distance compared to the athlete's current position";
