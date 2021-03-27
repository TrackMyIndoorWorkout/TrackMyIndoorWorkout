import 'dart:io';
import 'dart:convert';
import 'dart:math';

import '../devices/device_descriptors/device_descriptor.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../devices/device_map.dart';
import '../tcx/activity_type.dart';
import '../track/calculator.dart';
import '../track/tracks.dart';
import '../utils/statistics_accumulator.dart';
import 'tcx_model.dart';

class TCXOutput {
  static const MAJOR = '1';
  static const MINOR = '0';
  static const FILE_EXTENSION = 'tcx.gz';
  static const MIME_TYPE = 'application/x-gzip';

  StringBuffer _sb;

  StringBuffer get sb => _sb;

  TCXOutput() {
    _sb = StringBuffer();
  }

  TrackPoint recordToTrackPoint(Record record, TrackCalculator calculator) {
    final timeStamp = DateTime.fromMillisecondsSinceEpoch(record.timeStamp);
    final gps = calculator.gpsCoordinates(record.distance);
    return TrackPoint()
      ..longitude = gps.dx
      ..latitude = gps.dy
      ..timeStamp = TCXOutput.createTimestamp(timeStamp)
      ..altitude = calculator.track.altitude
      ..speed = record.speed * DeviceDescriptor.KMH2MS
      ..distance = record.distance
      ..date = timeStamp
      ..cadence = record.cadence
      ..power = record.power.toDouble()
      ..heartRate = record.heartRate;
  }

  Future<List<int>> getTcxOfActivity(Activity activity, List<Record> records, bool compress) async {
    final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
    final descriptor = deviceMap[activity.fourCC];
    final track = getDefaultTrack(descriptor.defaultSport);
    final calculator = TrackCalculator(track: track);
    TCXModel tcxInfo = TCXModel()
      ..activityType = descriptor.tcxSport
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

      // Related to software used to generate the TCX file
      ..author = 'Csaba Consulting'
      ..name = 'Track My Indoor Exercise'
      ..swVersionMajor = MAJOR
      ..swVersionMinor = MINOR
      ..buildVersionMajor = MAJOR
      ..buildVersionMinor = MINOR
      ..langID = 'en-US'
      ..partNumber = '0'
      ..points = records.map((r) => recordToTrackPoint(r, calculator)).toList();

    return await TCXOutput().getTcx(tcxInfo, compress);
  }

  Future<List<int>> getTcx(TCXModel tcxInfo, bool compress) async {
    generateTCX(tcxInfo);
    final stringBytes = utf8.encode(_sb.toString());
    if (!compress) {
      return stringBytes;
    }
    return GZipCodec(gzip: true).encode(stringBytes);
  }

  void generateTCX(TCXModel tcxInfo) {
    // The prolog of the TCX file
    _sb.write("""<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase
    xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd"
    xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1"
    xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2"
    xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2"
    xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns4="http://www.garmin.com/xmlschemas/ProfileExtension/v1">""");

    addActivity(tcxInfo);
    addAuthor(tcxInfo);

    _sb.write("</TrainingCenterDatabase>\n");
  }

  void addActivity(TCXModel tcxInfo) {
    // Add Activity
    //-------------
    _sb.write("""  <Activities>
    <Activity Sport="${tcxInfo.activityType}">\n""");

    // Add ID
    addElement('Id', createTimestamp(tcxInfo.dateActivity));
    addLap(tcxInfo);
    addCreator(tcxInfo);

    _sb.write("    </Activity>\n");
    _sb.write("  </Activities>\n");
  }

  void addLap(TCXModel tcxInfo) {
    // Add lap
    //---------
    _sb.write('        <Lap StartTime="${createTimestamp(tcxInfo.dateActivity)}">\n');

    // Assuming that points are ordered by time stamp ascending
    TrackPoint lastTrackPoint = tcxInfo.points.last;
    if (lastTrackPoint != null) {
      if ((tcxInfo.totalTime == null || tcxInfo.totalTime == 0) && lastTrackPoint.date != null) {
        tcxInfo.totalTime = lastTrackPoint.date.millisecondsSinceEpoch / 1000;
      }
      if ((tcxInfo.totalDistance == null || tcxInfo.totalDistance == 0) &&
          lastTrackPoint.distance > 0) {
        tcxInfo.totalDistance = lastTrackPoint.distance;
      }
    }

    addElement('TotalTimeSeconds', tcxInfo.totalTime.toString());
    // Add Total distance in meters
    addElement('DistanceMeters', tcxInfo.totalDistance.toStringAsFixed(2));

    final calculateMaxSpeed = tcxInfo.maxSpeed == null || tcxInfo.maxSpeed == 0;
    final calculateAvgHeartRate = tcxInfo.averageHeartRate == null || tcxInfo.averageHeartRate == 0;
    final calculateMaxHeartRate = tcxInfo.maximumHeartRate == null || tcxInfo.maximumHeartRate == 0;
    final calculateAvgCadence = tcxInfo.averageCadence == null || tcxInfo.averageCadence == 0;
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
      tcxInfo.points.forEach((trackPoint) {
        accu.processTrackPoint(trackPoint);
      });
    }
    if (calculateMaxSpeed) {
      tcxInfo.maxSpeed = accu.maxSpeed;
    }
    if (calculateAvgHeartRate && accu.heartRateCount > 0) {
      tcxInfo.averageHeartRate = accu.avgHeartRate;
    }
    if (calculateMaxHeartRate && accu.maxHeartRate > 0) {
      tcxInfo.maximumHeartRate = accu.maxHeartRate;
    }
    if (calculateAvgCadence && accu.cadenceCount > 0) {
      tcxInfo.averageCadence = accu.avgCadence;
    }

    // Add Maximum speed in meter/second
    addElement('MaximumSpeed', tcxInfo.maxSpeed.toStringAsFixed(2));

    if ((tcxInfo.averageHeartRate ?? 0) > 0) {
      addElement('AverageHeartRateBpm', tcxInfo.averageHeartRate.toStringAsFixed(2));
    }
    if ((tcxInfo.maximumHeartRate ?? 0) > 0) {
      addElement('MaximumHeartRateBpm', tcxInfo.maximumHeartRate.toString());
    }
    if ((tcxInfo.averageCadence ?? 0) > 0) {
      final cadence = min(max(tcxInfo.averageCadence, 0), 254).toInt();
      addElement('Cadence', cadence.toStringAsFixed(2));
    }

    // Add calories
    addElement('Calories', tcxInfo.calories.toString());
    // Add intensity (what is the meaning?)
    addElement('Intensity', 'Active');
    // Add intensity (what is the meaning?)
    addElement('TriggerMethod', 'Manual');

    addTrack(tcxInfo);

    _sb.write('        </Lap>\n');
  }

  void addTrack(TCXModel tcxInfo) {
    _sb.write('          <Track>\n');

    // Add track inside the lap
    for (var point in tcxInfo.points) {
      addTrackPoint(point);
    }

    _sb.write('          </Track>\n');
  }

  /// Generate a string that will include
  /// all the tags corresponding to TCX trackpoint
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

  void addCreator(TCXModel tcxInfo) {
    _sb.write("""    <Creator xsi:type="Device_t">
      <Name>${tcxInfo.deviceName}</Name>
      <UnitId>${tcxInfo.unitID}</UnitId>
      <ProductID>${tcxInfo.productID}</ProductID>
      <Version>
        <VersionMajor>${tcxInfo.versionMajor}</VersionMajor>
        <VersionMinor>${tcxInfo.versionMinor}</VersionMinor>
        <BuildMajor>${tcxInfo.buildMajor}</BuildMajor>
        <BuildMinor>${tcxInfo.buildMinor}</BuildMinor>
      </Version>
    </Creator>\n""");
  }

  void addAuthor(TCXModel tcxInfo) {
    _sb.write("""  <Author xsi:type="Application_t">
    <Name>${tcxInfo.author}</Name>
    <Build>
      <Version>
        <VersionMajor>${tcxInfo.versionMajor}</VersionMajor>
        <VersionMinor>${tcxInfo.versionMinor}</VersionMinor>
        <BuildMajor>${tcxInfo.buildMajor}</BuildMajor>
        <BuildMinor>${tcxInfo.buildMinor}</BuildMinor>
      </Version>
    </Build>
    <LangID>${tcxInfo.langID}</LangID>
    <PartNumber>${tcxInfo.partNumber}</PartNumber>
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
