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

const rankingForDevice = "Ranking Based on the Actual Device";
const rankingForDeviceTag = "ranking_for_device";
const rankingForDeviceDefault = false;
const rankingForDeviceDescription = "Should the app display ranking for the particular device. "
    "This affects both the ribbon type and the track visualization.";

const rankingForSport = "Ranking Based on the Whole Sport";
const rankingForSportTag = "ranking_for_sport";
const rankingForSportDefault = false;
const rankingForSportDescription = "Should the app display ranking for all devices for the sport. "
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
