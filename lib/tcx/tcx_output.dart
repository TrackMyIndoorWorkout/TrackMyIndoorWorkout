import 'dart:io';
import 'dart:convert';
import 'dart:math';

import '../devices/device_descriptor.dart';
import 'tcx_model.dart';

class StatisticsAccumulator {
  bool calculateMaxSpeed;
  bool calculateAverageHeartRate;
  bool calculateMaxHeartRate;
  bool calculateAverageCadence;

  double maxSpeed;
  int heartRateSum;
  int heartRateCount;
  int maxHeartRate;
  int cadenceSum;
  int cadenceCount;

  int get averageHeartRate =>
      heartRateCount > 0 ? heartRateSum / heartRateCount : 0;
  int get averageCadence => cadenceCount > 0 ? cadenceSum / cadenceCount : 0;

  StatisticsAccumulator(
      {this.calculateMaxSpeed,
      this.calculateAverageHeartRate,
      this.calculateMaxHeartRate,
      this.calculateAverageCadence}) {
    if (calculateMaxSpeed) {
      maxSpeed = 0;
    }
    if (calculateAverageHeartRate) {
      heartRateSum = 0;
      heartRateCount = 0;
    }
    if (calculateMaxHeartRate) {
      maxHeartRate = 0;
    }
    if (calculateAverageCadence) {
      cadenceSum = 0;
      cadenceCount = 0;
    }
  }

  StatisticsAccumulator processTrackPoint(TrackPoint trackPoint) {
    if (calculateMaxSpeed && trackPoint.speed != null) {
      maxSpeed = max(maxSpeed, trackPoint.speed);
    }
    if (trackPoint.heartRate != null && trackPoint.heartRate > 0) {
      if (calculateAverageHeartRate) {
        heartRateSum += trackPoint.heartRate;
        heartRateCount++;
      }
      if (calculateMaxHeartRate) {
        maxHeartRate = max(maxHeartRate, trackPoint.heartRate);
      }
    }
    if (calculateAverageCadence &&
        trackPoint.cadence != null &&
        trackPoint.cadence > 0) {
      cadenceSum += trackPoint.cadence;
      cadenceCount++;
    }
    return this;
  }
}

class TCXOutput {
  StringBuffer _sb;

  StringBuffer get sb => _sb;

  TCXOutput() {
    _sb = StringBuffer();
  }

  Future<List<int>> getTCX(TCXModel tcxInfo) async {
    generateTCX(tcxInfo);
    final stringBytes = utf8.encode(_sb.toString());
    return GZipCodec(gzip: true).encode(stringBytes);
  }

  generateTCX(TCXModel tcxInfo) {
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

  addActivity(TCXModel tcxInfo) {
    // Add Activity
    //-------------
    _sb.write("""  <Activities>
    <Activity Sport="${tcxInfo.activityType}">\n""");

    // Add ID
    addElement('Id', createTimestamp(tcxInfo.dateActivity));
    addLap(tcxInfo);
    addCreator(tcxInfo);

    _sb.write("    </Activities>\n");
    _sb.write("  </Activity>\n");
  }

  addLap(TCXModel tcxInfo) {
    // Add lap
    //---------
    _sb.write(
        '        <Lap StartTime="${createTimestamp(tcxInfo.dateActivity)}">\n');

    // Assuming that points are ordered by time stamp ascending
    TrackPoint lastTrackPoint = tcxInfo.points.last;
    if (lastTrackPoint != null) {
      if ((tcxInfo.totalTime == null || tcxInfo.totalTime == 0) &&
          lastTrackPoint.date != null) {
        tcxInfo.totalTime = lastTrackPoint.date.millisecondsSinceEpoch / 1000;
      }
      if ((tcxInfo.totalDistance == null || tcxInfo.totalDistance == 0) &&
          lastTrackPoint.distance > 0) {
        tcxInfo.totalDistance = lastTrackPoint.distance;
      }
    }

    addElement('TotalTimeSeconds', tcxInfo.totalTime.toString());
    // Add Total distance in meters
    addElement('DistanceMeters', tcxInfo.totalDistance.toString());

    final calculateMaxSpeed = tcxInfo.maxSpeed == null || tcxInfo.maxSpeed == 0;
    final calculateAverageHeartRate =
        tcxInfo.averageHeartRate == null || tcxInfo.averageHeartRate == 0;
    final calculateMaxHeartRate =
        tcxInfo.maximumHeartRate == null || tcxInfo.maximumHeartRate == 0;
    final calculateAverageCadence =
        tcxInfo.averageCadence == null || tcxInfo.averageCadence == 0;
    StatisticsAccumulator accu;
    if (calculateMaxSpeed ||
        calculateAverageHeartRate ||
        calculateMaxHeartRate ||
        calculateAverageCadence) {
      var accuInit = StatisticsAccumulator(
          calculateMaxSpeed: calculateMaxSpeed,
          calculateAverageHeartRate: calculateAverageHeartRate,
          calculateMaxHeartRate: calculateMaxHeartRate,
          calculateAverageCadence: calculateAverageCadence);
      accu = tcxInfo.points.fold<StatisticsAccumulator>(
          accuInit,
          (accumulator, trackPoint) =>
              accumulator.processTrackPoint(trackPoint));
    }
    if (calculateMaxSpeed) {
      tcxInfo.maxSpeed = accu.maxSpeed;
    }
    if (calculateAverageHeartRate) {
      tcxInfo.averageHeartRate = accu.averageHeartRate;
    }
    if (calculateMaxHeartRate) {
      tcxInfo.maximumHeartRate = accu.maxHeartRate;
    }
    if (calculateAverageCadence) {
      tcxInfo.averageCadence = accu.averageCadence;
    }

    // Add Maximum speed in meter/second
    addElement('MaximumSpeed', tcxInfo.maxSpeed.toString());

    if (tcxInfo.averageHeartRate != null) {
      addElement('AverageHeartRateBpm', tcxInfo.averageHeartRate.toString());
    }
    if (tcxInfo.maximumHeartRate != null) {
      addElement('MaximumHeartRateBpm', tcxInfo.maximumHeartRate.toString());
    }
    if (tcxInfo.averageCadence != null) {
      final cadence = min(max(tcxInfo.averageCadence, 0), 254).toInt();
      addElement('Cadence', cadence.toString());
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

  addTrack(TCXModel tcxInfo) {
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
  addTrackPoint(TrackPoint point) {
    _sb.write("<Trackpoint>\n");
    addElement('Time', point.timeStamp);
    addPosition(point.latitude.toString(), point.longitude.toString());
    addElement('AltitudeMeters', point.altitude.toString());
    addElement('DistanceMeters', point.distance.toString());
    if (point.cadence != null) {
      final cadence = min(max(point.cadence, 0), 254).toInt();
      addElement('Cadence', cadence.toString());
    }

    addExtension('Speed', point.speed);
    addExtension('Watts', point.power);

    if (point.heartRate != null) {
      addHeartRate(point.heartRate);
    }

    _sb.write("</Trackpoint>\n");
  }

  addCreator(TCXModel tcxInfo) {
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

  addAuthor(TCXModel tcxInfo) {
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

  /// Add an extension like
  ///
  ///  <Extensions>
  ///              <ns3:TPX>
  ///                <ns3:Speed>1.996999979019165</ns3:Speed>
  ///              </ns3:TPX>
  ///            </Extensions>
  ///
  /// Does not handle mutiple values like
  /// Speed AND Watts in the same extension
  ///
  addExtension(String tag, double value) {
    double _value = value ?? 0.0;
    _sb.write("""<Extensions>\n   <ns3:TPX>\n +
       <ns3:$tag>${_value.toString()}</ns3:$tag>\n +
     </ns3:TPX>\n</Extensions>\n""");
  }

  /// Add heartRate in TCX file to look like
  ///
  ///       <HeartRateBpm>
  ///         <Value>61</Value>
  ///       </HeartRateBpm>
  ///
  addHeartRate(int heartRate) {
    int _heartRate = heartRate ?? 0;
    _sb.write(
        """                 <HeartRateBpm xsi:type="HeartRateInBeatsPerMinute_t">
                <Value>${_heartRate.toString()}</Value>
              </HeartRateBpm>\n""");
  }

  /// create a position something like
  /// <Position>
  ///   <LatitudeDegrees>43.14029800705612</LatitudeDegrees>
  ///   <LongitudeDegrees>5.771340150386095</LongitudeDegrees>
  /// </Position>
  addPosition(String latitude, String longitude) {
    _sb.write("""<Position>\n
     <LatitudeDegrees>$latitude</LatitudeDegrees>\n
     <LongitudeDegrees>$longitude</LongitudeDegrees>\n
  </Position>\n""");
  }

  /// create XML element
  /// from content string
  addElement(String tag, String content) {
    _sb.write('<$tag>$content</$tag>\n');
  }

  /// create XML attribute
  /// from content string

  addAttribute(String tag, String attribute, String value, String content) {
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
