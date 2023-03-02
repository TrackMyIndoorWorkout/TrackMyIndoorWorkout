import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:tuple/tuple.dart';

import '../preferences/enforced_time_zone.dart';
import '../utils/constants.dart';
import '../utils/time_zone.dart';
import 'track_descriptor.dart';
import 'track_kind.dart';

class TrackManager {
  Map<String, Map<TrackKind, TrackDescriptor>> trackMaps = {
    // Hawaii time zone, UTC-10, US/Hawaii
    "Pacific/Honolulu": {
      TrackKind.forLand: TrackDescriptor(
        name: "AlohaStadium",
        kind: TrackKind.forLand,
        center: const Offset(-157.929905, 21.369667),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 7.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "AieaBay",
        kind: TrackKind.forWater,
        center: const Offset(-157.941302, 21.372486),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
    },
    // Alaska time zone, UTC-9, US/Alaska
    "America/Anchorage": {
      TrackKind.forLand: TrackDescriptor(
        name: "MulcahyStadium",
        kind: TrackKind.forLand,
        center: const Offset(-149.874875, 61.204890),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 19.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "LakeSpenard",
        kind: TrackKind.forWater,
        center: const Offset(-149.951304, 61.178096),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 24.0,
      ),
    },
    // US Pacific Time Zone, UTC-8, US/Pacific
    "America/Los_Angeles": {
      TrackKind.forRun: TrackDescriptor(
        name: "Marymoor",
        kind: TrackKind.forRun,
        center: const Offset(-122.112045, 47.665821),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 14.0,
      ),
      TrackKind.forRide: TrackDescriptor(
        name: "Hoover",
        kind: TrackKind.forRide,
        center: const Offset(-119.768433, 36.8195),
        radiusBoost: 1.1,
        horizontalMeter: 0.000011156,
        verticalMeter: 0.000009036,
        altitude: 96.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "SanJoaquinBluffPointe",
        kind: TrackKind.forWater,
        center: const Offset(-119.8730278, 36.84823845),
        radiusBoost: 1.2,
        horizontalMeter: 0.00001121,
        verticalMeter: 0.00000901,
        altitude: 68.0,
      ),
    },
    // US Mountain Time Zone, UTC-7, US/Mountain
    "America/Phoenix": {
      TrackKind.forLand: TrackDescriptor(
        name: "UofPStadiumYellowLot",
        kind: TrackKind.forLand,
        center: const Offset(-112.256361, 33.528765),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 324.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "LakeSpenard",
        kind: TrackKind.forWater,
        center: const Offset(-111.526130, 33.570095),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 464.0,
      ),
    },
    // US Central Time Zone, UTC-6, US/Central
    "America/Chicago": {
      TrackKind.forLand: TrackDescriptor(
        name: "VanderbiltLot74-75",
        kind: TrackKind.forLand,
        center: const Offset(-86.811341, 36.140955),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 169.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "CumberlandRiverDam",
        kind: TrackKind.forWater,
        center: const Offset(-86.645500, 36.286503),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 134.0,
      ),
    },
    // US Eastern Time Zone, UTC-5, US/Eastern
    "America/New_York": {
      TrackKind.forLand: TrackDescriptor(
        name: "JonesBeachParkingLot",
        kind: TrackKind.forLand,
        center: const Offset(-73.505493, 40.598631),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "ZachsBay",
        kind: TrackKind.forWater,
        center: const Offset(-73.489754, 40.601998),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
    },
    // VET Venezuelan Standard Time, UTC-4.5
    "America/Caracas": {
      TrackKind.forLand: TrackDescriptor(
        name: "RadiofaroOmnidireccionalVHFMaiquetía",
        kind: TrackKind.forLand,
        center: const Offset(-66.98968, 10.60948),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 71.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "PoertoLaGuaira",
        kind: TrackKind.forWater,
        center: const Offset(-66.940208, 10.600946),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 6.0,
      ),
    },
    // Atlantic Standard Time, UTC-4
    "America/Halifax": {
      TrackKind.forLand: TrackDescriptor(
        name: "TrailerParkBoysLot",
        kind: TrackKind.forLand,
        center: const Offset(-63.542753, 44.673775),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 63.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "MorrisLake",
        kind: TrackKind.forWater,
        center: const Offset(-63.496622, 44.651401),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 28.0,
      ),
    },
    // Brasilia Standard Time, UTC-3
    "America/Buenos_Aires": {
      TrackKind.forLand: TrackDescriptor(
        name: "RioDeJaneiroAirport",
        kind: TrackKind.forLand,
        center: const Offset(-43.164751, -22.912775),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 7.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "LagueRodrigoDeFreitas",
        kind: TrackKind.forWater,
        center: const Offset(-43.211437, -22.972039),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 6.0,
      ),
    },
    // Cape Verde Time (CVT), UTC-1
    "Atlantic/Cape_Verde": {
      TrackKind.forLand: TrackDescriptor(
        name: "SalinasPortoInglesMaioLand",
        kind: TrackKind.forLand,
        center: const Offset(-23.222874, 15.150392),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "SalinasPortoInglesMaioWater",
        kind: TrackKind.forWater,
        center: const Offset(-23.222874, 15.150392),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
    },
    // GMT, UTC
    "Europe/London": {
      TrackKind.forLand: TrackDescriptor(
        name: "GatwickAirportSideTarmac",
        kind: TrackKind.forLand,
        center: const Offset(-0.187445, 51.153249),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 56.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "WraysburyReservoir",
        kind: TrackKind.forWater,
        center: const Offset(-0.524808, 51.462237),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 28.0,
      ),
    },
    // Central European Time, UTC+1
    "Europe/Budapest": {
      TrackKind.forLand: TrackDescriptor(
        name: "HeroesSquare",
        kind: TrackKind.forLand,
        center: const Offset(19.077773, 47.514957),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 106.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "LupaLake",
        kind: TrackKind.forWater,
        center: const Offset(19.076887, 47.629238),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 97.0,
      ),
    },
    // Eastern European Time, UTC+2
    "Europe/Bucharest": {
      TrackKind.forLand: TrackDescriptor(
        name: "BaneasaShoppingCityParkingLot",
        kind: TrackKind.forLand,
        center: const Offset(26.087319, 44.508728),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 88.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "LaculMorii",
        kind: TrackKind.forWater,
        center: const Offset(26.033653, 44.452841),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 81.0,
      ),
    },
    // Istambul Time, UTC+3
    "Europe/Istanbul": {
      TrackKind.forLand: TrackDescriptor(
        name: "IstanbulHavalimaniSideTarmac",
        kind: TrackKind.forLand,
        center: const Offset(28.716875, 41.295379),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 60.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "GoldenHornIstanbul",
        kind: TrackKind.forWater,
        center: const Offset(28.959516, 41.030587),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
    },
    // Iranian Time, UTC+3.5
    "Asia/Tehran": {
      TrackKind.forLand: TrackDescriptor(
        name: "MehrabadAirBaseSideTarmac",
        kind: TrackKind.forLand,
        center: const Offset(51.314826, 35.683827),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 1174.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "ChitgarLakeTehran",
        kind: TrackKind.forWater,
        center: const Offset(51.213890, 35.745086),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 1268.0,
      ),
    },
    // Armenian Time, UTC+4
    "Asia/Yerevan": {
      TrackKind.forLand: TrackDescriptor(
        name: "YerevanAirportSideTarmac",
        kind: TrackKind.forLand,
        center: const Offset(44.407696, 40.150749),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 860.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "YerevanyanLake",
        kind: TrackKind.forWater,
        center: const Offset(44.477948, 40.160367),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 906.0,
      ),
    },
    // Afghanistan Time, UTC+4.5
    "Asia/Kabul": {
      TrackKind.forLand: TrackDescriptor(
        name: "KabulAirportSideTarmac",
        kind: TrackKind.forLand,
        center: const Offset(69.217713, 34.568202),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 1788.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "QuarghaReservoir",
        kind: TrackKind.forWater,
        center: const Offset(69.033618, 34.556452),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 1987.0,
      ),
    },
    // Pakistan Time, UTC+5
    "Asia/Karachi": {
      TrackKind.forLand: TrackDescriptor(
        name: "JinnahAirportSideTarmacKarachi",
        kind: TrackKind.forLand,
        center: const Offset(67.148441, 24.897003),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 17.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "LagoonNearKarachiPort",
        kind: TrackKind.forWater,
        center: const Offset(66.954419, 24.840263),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
    },
    // Indian Time, UTC+5.5
    "Asia/Kolkata": {
      TrackKind.forLand: TrackDescriptor(
        name: "ShabbarVallabhbhaaiPatelAirportAhmedabadGujarat",
        kind: TrackKind.forLand,
        center: const Offset(72.626126, 23.073872),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 54.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "KankariaLakeAhmedabad",
        kind: TrackKind.forWater,
        center: const Offset(72.599662, 23.006220),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 47.0,
      ),
    },
    // Kazakhstan Time, UTC+6
    "Asia/Almaty": {
      TrackKind.forLand: TrackDescriptor(
        name: "AlmatyAirport",
        kind: TrackKind.forLand,
        center: const Offset(77.014195, 43.343786),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 676.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "LakeSorbulaq",
        kind: TrackKind.forWater,
        center: const Offset(76.571940, 43.668614),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 618.0,
      ),
    },
    // Vietnam, Thailand Time, UTC+7
    "Asia/Saigon": {
      TrackKind.forLand: TrackDescriptor(
        name: "TanSonNhatAirportSideTarmac",
        kind: TrackKind.forLand,
        center: const Offset(106.660137, 10.812661),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 10.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "TuyetTinhCocHoaAn",
        kind: TrackKind.forWater,
        center: const Offset(106.795240, 10.927931),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: -53.0,
      ),
    },
    // Western Australia, UTC+8
    "Australia/Perth": {
      TrackKind.forLand: TrackDescriptor(
        name: "PerthAirportSideTarmac",
        kind: TrackKind.forLand,
        center: const Offset(115.968893, -31.946402),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 19.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "BibraLakePerth",
        kind: TrackKind.forWater,
        center: const Offset(115.825696, -32.095313),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 14.0,
      ),
    },
    // Korea, Japan, UTC+9
    "Asia/Seoul": {
      TrackKind.forLand: TrackDescriptor(
        name: "IncheonAirportTarmac",
        kind: TrackKind.forLand,
        center: const Offset(126.438003, 37.463765),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "YellowSeaPortofIncheon",
        kind: TrackKind.forWater,
        center: const Offset(126.610885, 37.465361),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
    },
    // Mid South Australia, UTC+9.5
    "Australia/Adelaide": {
      TrackKind.forLand: TrackDescriptor(
        name: "GenisSteelParkingLot",
        kind: TrackKind.forLand,
        center: const Offset(138.651371, -34.751084),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 38.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "HopeValleyReservoir",
        kind: TrackKind.forWater,
        center: const Offset(138.682459, -34.851559),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 104.0,
      ),
    },
    // Mid North Australia, UTC+9.5?
    "Australia/Darwin": {
      TrackKind.forLand: TrackDescriptor(
        name: "DarwinAirportSideTarmac",
        kind: TrackKind.forLand,
        center: const Offset(130.867281, -12.417536),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 31.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "TimorSeaBay",
        kind: TrackKind.forWater,
        center: const Offset(130.854498, -12.455684),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
    },
    // East Australia, UTC+10
    "Australia/Sydney": {
      TrackKind.forLand: TrackDescriptor(
        name: "SydneyAirportSideTarmac",
        kind: TrackKind.forLand,
        center: const Offset(151.188888, -33.936817),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 5.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "ChippingNortonLake",
        kind: TrackKind.forWater,
        center: const Offset(150.958685, -33.902295),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 2.0,
      ),
    },
    // New Zealand, UTC+12
    "Pacific/Auckland": {
      TrackKind.forLand: TrackDescriptor(
        name: "AucklandAirportTarmac",
        kind: TrackKind.forLand,
        center: const Offset(174.783718, -37.008289),
        radiusBoost: 1.1,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 6.0,
      ),
      TrackKind.forWater: TrackDescriptor(
        name: "PahurehureInlet",
        kind: TrackKind.forWater,
        center: const Offset(174.878590, -37.061558),
        radiusBoost: 1.2,
        horizontalMeter: 0.000013337,
        verticalMeter: 0.000008985,
        altitude: 0.0,
      ),
    },
  };

  int timeZoneOffset(String timeZoneName) {
    DateTime? now;
    if (timeZoneName == enforcedTimeZoneDefault) {
      now = DateTime.now();
    } else {
      var location = tz.getLocation(timeZoneName);
      now = tz.TZDateTime.now(location);
    }

    return now.timeZoneOffset.inMinutes;
  }

  Future<TrackDescriptor> getTrack(String sport) async {
    final timeZoneName = await getTimeZone();
    final timeOffset = timeZoneOffset(timeZoneName) + 5; // 5 is to break a tie
    final timeZoneEntries = trackMaps.keys
        .map<Tuple2<int, String>>((tzName) => Tuple2<int, String>(timeZoneOffset(tzName), tzName))
        .sortedByCompare((tp) => tp.item1, (int t1, int t2) => t1.compareTo(t2))
        .toList(growable: false);
    Tuple2<int, String> previousEntry = const Tuple2<int, String>(maxUint24, "");
    Tuple2<int, String> currentEntry = const Tuple2<int, String>(maxUint24, "");
    for (final timeZoneEntry in timeZoneEntries) {
      currentEntry = timeZoneEntry;
      if (timeZoneEntry.item1 > timeOffset) {
        break;
      }

      previousEntry = timeZoneEntry;
    }

    Tuple2<int, String> closestEntry = const Tuple2<int, String>(maxUint24, "");
    if (previousEntry.item1 != maxUint24 && currentEntry.item1 != maxUint24) {
      if ((previousEntry.item1 - timeOffset).abs() < (currentEntry.item1 - timeOffset).abs()) {
        closestEntry = previousEntry;
      } else {
        closestEntry = currentEntry;
      }
    }

    if (closestEntry.item1 == maxUint24) {
      // Default to GMT
      closestEntry = timeZoneEntries.firstWhere((entry) => entry.item2 == "Europe/London");
    }

    Map<TrackKind, TrackDescriptor> timeZoneTracks = trackMaps[closestEntry.item2]!;
    TrackDescriptor track = trackMaps["Europe/London"]![TrackKind.forLand]!;
    for (final trackKind in getTrackKindForSport(sport)) {
      if (timeZoneTracks.containsKey(trackKind)) {
        track = timeZoneTracks[trackKind]!;
        break;
      }
    }

    return track;
  }
}
