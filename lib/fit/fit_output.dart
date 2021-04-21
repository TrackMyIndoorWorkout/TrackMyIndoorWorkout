import 'dart:io';
import 'dart:convert';
import 'dart:math';

import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_map.dart';
import '../export/tcx/tcx_model.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../track/calculator.dart';
import '../track/tracks.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import '../utils/statistics_accumulator.dart';

class FitOutput {
  static const MAJOR = '1';
  static const MINOR = '0';
  static const FILE_EXTENSION = 'fit';
  static const COMPRESSED_FILE_EXTENSION = FILE_EXTENSION + '.gz';
  static const MIME_TYPE = 'text/xml';
  static const COMPRESSED_MIME_TYPE = 'application/x-gzip';

  List<int> _bytes;

  StringBuffer _sb;

  FitOutput() {
    _bytes = [];
  }

  static String fileExtension(bool compressed) {
    return compressed ? COMPRESSED_FILE_EXTENSION : FILE_EXTENSION;
  }

  static String mimeType(bool compressed) {
    return compressed ? COMPRESSED_MIME_TYPE : MIME_TYPE;
  }

  TrackPoint recordToTrackPoint(Record record, TrackCalculator calculator) {
    final timeStamp = DateTime.fromMillisecondsSinceEpoch(record.timeStamp);
    final gps = calculator.gpsCoordinates(record.distance);
    return TrackPoint()
      ..longitude = gps.dx
      ..latitude = gps.dy
      ..timeStamp = FitOutput.createTimestamp(timeStamp)
      ..altitude = calculator.track.altitude
      ..speed = record.speed * DeviceDescriptor.KMH2MS
      ..distance = record.distance ?? 0.0
      ..date = timeStamp
      ..cadence = record.cadence
      ..power = record.power.toDouble()
      ..heartRate = record.heartRate;
  }

  Future<List<int>> getFitOfActivity(Activity activity, List<Record> records, bool compress) async {
    final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
    final descriptor = deviceMap[activity.fourCC];
    final track = getDefaultTrack(activity.sport);
    final calculator = TrackCalculator(track: track);
    TCXModel fitInfo = TCXModel()
      ..activityType = tcxSport(activity.sport)
      ..totalDistance = activity.distance
      ..totalTime = activity.elapsed.toDouble()
      ..calories = activity.calories
      ..dateActivity = startStamp

      // Related to device that generated the data
      ..creator = descriptor.vendorName
      ..deviceName = descriptor.fullName
      ..unitID = activity.deviceId
      ..productID = descriptor.modelName
      ..versionMajor = MAJOR
      ..versionMinor = MINOR
      ..buildMajor = MAJOR
      ..buildMinor = MINOR

      // Related to software used to generate the FIT file
      ..author = 'Csaba Consulting'
      ..name = 'Track My Indoor Exercise'
      ..swVersionMajor = MAJOR
      ..swVersionMinor = MINOR
      ..buildVersionMajor = MAJOR
      ..buildVersionMinor = MINOR
      ..langID = 'en-US'
      ..partNumber = '0'
      ..points = records.map((r) => recordToTrackPoint(r, calculator)).toList(growable: false);

    return await FitOutput().getFit(fitInfo, compress);
  }

  Future<List<int>> getFit(TCXModel fitInfo, bool compress) async {
    generateFit(fitInfo);
    final stringBytes = utf8.encode(_sb.toString());
    if (!compress) {
      return stringBytes;
    }
    return GZipCodec(gzip: true).encode(stringBytes);
  }

  void generateFit(TCXModel fitInfo) {
    // The prolog of the TCX file
    _sb.write("""<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase
    xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd"
    xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1"
    xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2"
    xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2"
    xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns4="http://www.garmin.com/xmlschemas/ProfileExtension/v1">""");

    addActivity(fitInfo);
    addAuthor(fitInfo);

    _sb.write("</TrainingCenterDatabase>\n");
  }

  void addActivity(TCXModel fitInfo) {
    // Add Activity
    //-------------
    _sb.write("""  <Activities>
    <Activity Sport="${fitInfo.activityType}">\n""");

    // Add ID
    addElement('Id', createTimestamp(fitInfo.dateActivity));
    addLap(fitInfo);
    addCreator(fitInfo);

    _sb.write("    </Activity>\n");
    _sb.write("  </Activities>\n");
  }

  void addLap(TCXModel fitInfo) {
    // Add lap
    //---------
    _sb.write('        <Lap StartTime="${createTimestamp(fitInfo.dateActivity)}">\n');

    // Assuming that points are ordered by time stamp ascending
    TrackPoint lastTrackPoint = fitInfo.points.last;
    if (lastTrackPoint != null) {
      if ((fitInfo.totalTime == null || fitInfo.totalTime == 0) && lastTrackPoint.date != null) {
        fitInfo.totalTime = lastTrackPoint.date.millisecondsSinceEpoch / 1000;
      }
      if ((fitInfo.totalDistance == null || fitInfo.totalDistance == 0) &&
          lastTrackPoint.distance > 0) {
        fitInfo.totalDistance = lastTrackPoint.distance;
      }
    }

    addElement('TotalTimeSeconds', fitInfo.totalTime.toString());
    // Add Total distance in meters
    addElement('DistanceMeters', fitInfo.totalDistance.toStringAsFixed(2));

    final calculateMaxSpeed = fitInfo.maxSpeed == null || fitInfo.maxSpeed == 0;
    final calculateAvgHeartRate = fitInfo.averageHeartRate == null || fitInfo.averageHeartRate == 0;
    final calculateMaxHeartRate = fitInfo.maximumHeartRate == null || fitInfo.maximumHeartRate == 0;
    final calculateAvgCadence = fitInfo.averageCadence == null || fitInfo.averageCadence == 0;
    var accu = StatisticsAccumulator(
      si: true,
      sport: ActivityType.Ride,
      calculateMaxSpeed: calculateMaxSpeed,
      calculateAvgHeartRate: calculateAvgHeartRate,
      calculateMaxHeartRate: calculateMaxHeartRate,
      calculateAvgCadence: calculateAvgCadence,
    );
    if (calculateMaxSpeed ||
        calculateAvgHeartRate ||
        calculateMaxHeartRate ||
        calculateAvgCadence) {
      fitInfo.points.forEach((trackPoint) {
        accu.processTrackPoint(trackPoint);
      });
    }
    if (calculateMaxSpeed) {
      fitInfo.maxSpeed = accu.maxSpeed;
    }
    if (calculateAvgHeartRate && accu.heartRateCount > 0) {
      fitInfo.averageHeartRate = accu.avgHeartRate;
    }
    if (calculateMaxHeartRate && accu.maxHeartRate > 0) {
      fitInfo.maximumHeartRate = accu.maxHeartRate;
    }
    if (calculateAvgCadence && accu.cadenceCount > 0) {
      fitInfo.averageCadence = accu.avgCadence;
    }

    // Add Maximum speed in meter/second
    addElement('MaximumSpeed', fitInfo.maxSpeed.toStringAsFixed(2));

    if ((fitInfo.averageHeartRate ?? 0) > 0) {
      addElement('AverageHeartRateBpm', fitInfo.averageHeartRate.toStringAsFixed(2));
    }
    if ((fitInfo.maximumHeartRate ?? 0) > 0) {
      addElement('MaximumHeartRateBpm', fitInfo.maximumHeartRate.toString());
    }
    if ((fitInfo.averageCadence ?? 0) > 0) {
      final cadence = min(max(fitInfo.averageCadence, 0), 254).toInt();
      addElement('Cadence', cadence.toStringAsFixed(2));
    }

    // Add calories
    addElement('Calories', fitInfo.calories.toString());
    // Add intensity (what is the meaning?)
    addElement('Intensity', 'Active');
    // Add intensity (what is the meaning?)
    addElement('TriggerMethod', 'Manual');

    addTrack(fitInfo);

    _sb.write('        </Lap>\n');
  }

  void addTrack(TCXModel fitInfo) {
    _sb.write('          <Track>\n');

    // Add track inside the lap
    for (var point in fitInfo.points) {
      addTrackPoint(point);
    }

    _sb.write('          </Track>\n');
  }

  /// Generate a string that will include
  /// all the tags corresponding to FIT track point
  ///
  /// Extension handling is missing for the moment
  ///
  void addTrackPoint(TrackPoint point) {
    _sb.write("<Trackpoint>\n");
    addElement('Time', point.timeStamp);
    addPosition(point.latitude.toStringAsFixed(10), point.longitude.toStringAsFixed(10));
    addElement('AltitudeMeters', point.altitude.toString());
    addElement('DistanceMeters', point.distance.toStringAsFixed(2));
    if (point.cadence != null) {
      final cadence = min(max(point.cadence, 0), 254).toInt();
      addElement('Cadence', cadence.toString());
    }

    addExtensions('Speed', point.speed.toStringAsFixed(2), 'Watts', point.power);

    if (point.heartRate != null) {
      addHeartRate(point.heartRate);
    }

    _sb.write("</Trackpoint>\n");
  }

  void addCreator(TCXModel fitInfo) {
    _sb.write("""    <Creator xsi:type="Device_t">
      <Name>${fitInfo.deviceName}</Name>
      <UnitId>${fitInfo.unitID}</UnitId>
      <ProductID>${fitInfo.productID}</ProductID>
      <Version>
        <VersionMajor>${fitInfo.versionMajor}</VersionMajor>
        <VersionMinor>${fitInfo.versionMinor}</VersionMinor>
        <BuildMajor>${fitInfo.buildMajor}</BuildMajor>
        <BuildMinor>${fitInfo.buildMinor}</BuildMinor>
      </Version>
    </Creator>\n""");
  }

  void addAuthor(TCXModel fitInfo) {
    _sb.write("""  <Author xsi:type="Application_t">
    <Name>${fitInfo.author}</Name>
    <Build>
      <Version>
        <VersionMajor>${fitInfo.versionMajor}</VersionMajor>
        <VersionMinor>${fitInfo.versionMinor}</VersionMinor>
        <BuildMajor>${fitInfo.buildMajor}</BuildMajor>
        <BuildMinor>${fitInfo.buildMinor}</BuildMinor>
      </Version>
    </Build>
    <LangID>${fitInfo.langID}</LangID>
    <PartNumber>${fitInfo.partNumber}</PartNumber>
  </Author>\n""");
  }

  /// Add extension of speed and watts
  ///
  ///  <Extensions>
  ///              <ns3:TPX>
  ///                <ns3:Speed>1.996999979019165</ns3:Speed>
  ///              </ns3:TPX>
  ///            </Extensions>
  ///
  /// Does not handle multiple values like
  /// Speed AND Watts in the same extension
  ///
  void addExtensions(String tag1, String value1, String tag2, double value2) {
    double _value = value2 ?? 0.0;
    _sb.write("""    <Extensions>
      <ns3:TPX>
        <ns3:$tag1>$value1</ns3:$tag1>
        <ns3:$tag2>${_value.toString()}</ns3:$tag2>
      </ns3:TPX>
    </Extensions>\n""");
  }

  /// Add heartRate in TCX file to look like
  ///
  ///       <HeartRateBpm>
  ///         <Value>61</Value>
  ///       </HeartRateBpm>
  ///
  void addHeartRate(int heartRate) {
    int _heartRate = heartRate ?? 0;
    _sb.write("""                 <HeartRateBpm xsi:type="HeartRateInBeatsPerMinute_t">
                <Value>${_heartRate.toString()}</Value>
              </HeartRateBpm>\n""");
  }

  /// create a position something like
  /// <Position>
  ///   <LatitudeDegrees>43.14029800705612</LatitudeDegrees>
  ///   <LongitudeDegrees>5.771340150386095</LongitudeDegrees>
  /// </Position>
  void addPosition(String latitude, String longitude) {
    _sb.write("""<Position>
     <LatitudeDegrees>$latitude</LatitudeDegrees>
     <LongitudeDegrees>$longitude</LongitudeDegrees>
  </Position>\n""");
  }

  /// create XML element
  /// from content string
  void addElement(String tag, String content) {
    _sb.write('<$tag>$content</$tag>\n');
  }

  /// create XML attribute
  /// from content string

  void addAttribute(String tag, String attribute, String value, String content) {
    _sb.write('<$tag $attribute="$value">\n$content</$tag>\n');
  }

  /// Create timestamp for <Time> element in TCX file
  ///
  /// To get 2019-03-03T11:43:46.000Z
  /// utc time
  /// Need to add T in the middle
  static String createTimestamp(DateTime dateTime) {
    return dateTime.toUtc().toString().replaceFirst(' ', 'T');
  }
}
