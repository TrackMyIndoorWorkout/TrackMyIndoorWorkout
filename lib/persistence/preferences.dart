const LEADERBOARD_FEATURE = "Leaderboard Feature";
const LEADERBOARD_FEATURE_TAG = "leaderboard_feature";
const LEADERBOARD_FEATURE_DEFAULT = false;
const LEADERBOARD_FEATURE_DESCRIPTION =
    "Leaderboard registry: should the app record workout entries for leaderboard purposes.";

const RANK_RIBBON_VISUALIZATION = "Display Rank Ribbons Above the Speed Graph";
const RANK_RIBBON_VISUALIZATION_TAG = "rank_ribbon_visualization";
const RANK_RIBBON_VISUALIZATION_DEFAULT = false;
const RANK_RIBBON_VISUALIZATION_DESCRIPTION =
    "Should the app provide UI feedback by ribbons above the speed graph. "
    "Blue color means behind the top leaderboard, green marks record pace.";

const RANKING_FOR_DEVICE = "Ranking Based on the Actual Device";
const RANKING_FOR_DEVICE_TAG = "ranking_for_device";
const RANKING_FOR_DEVICE_DEFAULT = false;
const RANKING_FOR_DEVICE_DESCRIPTION = "Should the app display ranking for the particular device. "
    "This affects both the ribbon type and the track visualization.";

const RANKING_FOR_SPORT = "Ranking Based on the Whole Sport";
const RANKING_FOR_SPORT_TAG = "ranking_for_sport";
const RANKING_FOR_SPORT_DEFAULT = false;
const RANKING_FOR_SPORT_DESCRIPTION =
    "Should the app display ranking for all devices for the sport. "
    "This affects both the ribbon type and the track visualization.";

const RANK_TRACK_VISUALIZATION = "Visualize Rank Positions on the Track";
const RANK_TRACK_VISUALIZATION_TAG = "rank_track_visualization";
const RANK_TRACK_VISUALIZATION_DEFAULT = false;
const RANK_TRACK_VISUALIZATION_DESCRIPTION =
    "For performance reasons only the position right ahead (green color) and right behind "
    "(blue color) of the current effort is displayed. Both positions have a the rank "
    "number inside their dot.";

const RANK_INFO_ON_TRACK =
    "Display rank information at the center of the track (on top of positions)";
const RANK_INFO_ON_TRACK_TAG = "rank_info_on_track";
const RANK_INFO_ON_TRACK_DEFAULT = true;
const RANK_INFO_ON_TRACK_DESCRIPTION =
    "On: when rank position is enabled this switch will display extra information "
    "in the middle of the track: it'll list the preceding and following positions "
    "along with the distance compared to the athlete's current position";

const DISPLAY_LAP_COUNTER = "Display the number of lamps";
const DISPLAY_LAP_COUNTER_TAG = "display_lap_counter";
const DISPLAY_LAP_COUNTER_DEFAULT = false;
const DISPLAY_LAP_COUNTER_DESCRIPTION =
    "On: the number of lamps passed will be displayed in the middle of the track";

const ZONE_INDEX_DISPLAY_COLORING = "Color the measurement based on zones";
const ZONE_INDEX_DISPLAY_COLORING_TAG = "zone_index_display_coloring";
const ZONE_INDEX_DISPLAY_COLORING_DEFAULT = true;
const ZONE_INDEX_DISPLAY_COLORING_DESCRIPTION =
    "On: The measurement font and background is color modified to reflect the zone value. "
    "Off: The zone is displayed without any re-coloring, this is less performance intensive.";
