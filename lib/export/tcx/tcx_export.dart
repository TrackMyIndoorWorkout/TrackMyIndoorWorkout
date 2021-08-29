import 'dart:convert';
import 'dart:math';

import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../activity_export.dart';
import '../export_model.dart';
import '../export_record.dart';

class TCXExport extends ActivityExport {
  StringBuffer _sb = StringBuffer();

  TCXExport() : super(nonCompressedFileExtension: 'tcx', nonCompressedMimeType: 'text/xml');

  static String tcxSport(String sport) {
    return sport == ActivityType.Ride || sport == ActivityType.Run ? sport : "Other";
  }

  Future<List<int>> getFileCore(ExportModel exportModel) async {
    // The prolog of the TCX file
    _sb.writeln("""<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase
    xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd"
    xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1"
    xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2"
    xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2"
    xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns4="http://www.garmin.com/xmlschemas/ProfileExtension/v1">""");

    addActivity(exportModel);
    addAuthor(exportModel);

    _sb.writeln("</TrainingCenterDatabase>");

    return utf8.encode(_sb.toString());
  }

  void addActivity(ExportModel exportModel) {
    final activityType = tcxSport(exportModel.activity.sport);
    // Add Activity
    //-------------
    _sb.writeln("""  <Activities>
    <Activity Sport="$activityType">""");

    // Add ID
    final dateActivity = DateTime.fromMillisecondsSinceEpoch(exportModel.activity.start);
    addElement('Id', timeStampString(dateActivity));
    addLap(exportModel);
    addCreator(exportModel);

    _sb.writeln("    </Activity>");
    _sb.writeln("  </Activities>");
  }

  void addLap(ExportModel exportModel) {
    // Add lap
    //---------
    final dateActivity = DateTime.fromMillisecondsSinceEpoch(exportModel.activity.start);
    _sb.writeln('        <Lap StartTime="${timeStampString(dateActivity)}">');

    addElement('TotalTimeSeconds', exportModel.activity.elapsed.toStringAsFixed(1));
    // Add Total distance in meters
    addElement('DistanceMeters', exportModel.activity.distance.toStringAsFixed(2));

    // Add Maximum speed in meter/second
    addElement('MaximumSpeed', exportModel.maximumSpeed.toStringAsFixed(2));

    if (exportModel.averageHeartRate > 0) {
      addElement('AverageHeartRateBpm', exportModel.averageHeartRate.toStringAsFixed(2));
    }
    if (exportModel.maximumHeartRate > 0) {
      addElement('MaximumHeartRateBpm', exportModel.maximumHeartRate.toString());
    }
    if (exportModel.averageCadence > 0) {
      final cadence = min(max(exportModel.averageCadence, 0), 254).toInt();
      addElement('Cadence', cadence.toStringAsFixed(2));
    }

    // Add calories
    addElement('Calories', exportModel.activity.calories.toString());
    // Add intensity (what is the meaning?)
    addElement('Intensity', 'Active');
    // Add intensity (what is the meaning?)
    addElement('TriggerMethod', 'Manual');

    addTrack(exportModel);

    _sb.writeln('        </Lap>');
  }

  void addTrack(ExportModel exportModel) {
    _sb.writeln('          <Track>');

    // Add track inside the lap
    for (var record in exportModel.records) {
      addTrackPoint(record, exportModel);
    }

    _sb.writeln('          </Track>');
  }

  /// Generate a string that will include
  /// all the tags corresponding to TCX trackpoint
  ///
  /// Extension handling is missing for the moment
  ///
  void addTrackPoint(ExportRecord record, ExportModel exportModel) {
    _sb.writeln("<Trackpoint>");
    addElement('Time', record.timeStampString);
    addPosition(record.latitude.toStringAsFixed(7), record.longitude.toStringAsFixed(7));
    addElement('AltitudeMeters', exportModel.altitude.toString());
    addElement('DistanceMeters', (record.record.distance ?? 0.0).toStringAsFixed(2));
    if (record.record.cadence != null) {
      final cadence = min(max(record.record.cadence!, 0), 254).toInt();
      addElement('Cadence', cadence.toString());
    }

    addExtensions(
      'Speed',
      (record.record.speed ?? 0.0).toStringAsFixed(2),
      'Watts',
      (record.record.power ?? 0).toStringAsFixed(1),
    );

    if ((record.record.heartRate ?? 0) > 0 ||
        heartRateGapWorkaround == DATA_GAP_WORKAROUND_NO_WORKAROUND ||
        heartRateLimitingMethod == HEART_RATE_LIMITING_WRITE_ZERO) {
      addHeartRate(record.record.heartRate);
    }

    _sb.writeln("</Trackpoint>");
  }

  void addCreator(ExportModel exportModel) {
    _sb.writeln("""    <Creator xsi:type="Device_t">
      <Name>${exportModel.descriptor.fullName}</Name>
      <UnitId>${exportModel.activity.deviceId}</UnitId>
      <ProductID>${exportModel.descriptor.modelName}</ProductID>
      <Version>
        <VersionMajor>$major</VersionMajor>
        <VersionMinor>$minor</VersionMinor>
        <BuildMajor>$major</BuildMajor>
        <BuildMinor>$minor</BuildMinor>
      </Version>
    </Creator>""");
  }

  void addAuthor(ExportModel exportModel) {
    _sb.writeln("""  <Author xsi:type="Application_t">
    <Name>${exportModel.author}</Name>
    <Build>
      <Version>
        <VersionMajor>${exportModel.swVersionMajor}</VersionMajor>
        <VersionMinor>${exportModel.swVersionMinor}</VersionMinor>
        <BuildMajor>${exportModel.buildVersionMajor}</BuildMajor>
        <BuildMinor>${exportModel.buildVersionMinor}</BuildMinor>
      </Version>
    </Build>
    <LangID>${exportModel.langID}</LangID>
    <PartNumber>${exportModel.partNumber}</PartNumber>
  </Author>""");
  }

  /// Add extension of speed and watts
  ///
  ///  <Extensions>
  ///              <ns3:TPX>
  ///                <ns3:Speed>1.996999979019165</ns3:Speed>
  ///                <ns3:Watts>87.0</ns3:Watts>
  ///              </ns3:TPX>
  ///            </Extensions>
  ///
  /// Does not handle multiple values like
  /// Speed AND Watts in the same extension
  ///
  void addExtensions(String tag1, String value1, String tag2, String value2) {
    _sb.writeln("""    <Extensions>
      <ns3:TPX>
        <ns3:$tag1>$value1</ns3:$tag1>
        <ns3:$tag2>$value2</ns3:$tag2>
      </ns3:TPX>
    </Extensions>""");
  }

  /// Add heartRate in TCX file to look like
  ///
  ///       <HeartRateBpm>
  ///         <Value>61</Value>
  ///       </HeartRateBpm>
  ///
  void addHeartRate(int? heartRate) {
    int _heartRate = heartRate ?? 0;
    _sb.writeln("""                 <HeartRateBpm xsi:type="HeartRateInBeatsPerMinute_t">
                <Value>${_heartRate.toString()}</Value>
              </HeartRateBpm>""");
  }

  /// create a position something like
  /// <Position>
  ///   <LatitudeDegrees>43.14029800705612</LatitudeDegrees>
  ///   <LongitudeDegrees>5.771340150386095</LongitudeDegrees>
  /// </Position>
  void addPosition(String latitude, String longitude) {
    _sb.writeln("""<Position>
     <LatitudeDegrees>$latitude</LatitudeDegrees>
     <LongitudeDegrees>$longitude</LongitudeDegrees>
  </Position>""");
  }

  /// create XML element
  /// from content string
  void addElement(String tag, String content) {
    _sb.writeln('<$tag>$content</$tag>');
  }

  /// create XML attribute
  /// from content string
  void addAttribute(String tag, String attribute, String value, String content) {
    _sb.writeln('<$tag $attribute="$value">$content</$tag>');
  }

  /// Create timestamp for <Time> element in TCX file
  ///
  /// To get 2019-03-03T11:43:46.000Z
  /// utc time
  /// Need to add T in the middle
  String timeStampString(DateTime dateTime) {
    return dateTime.toUtc().toString().replaceFirst(' ', 'T');
  }

  int timeStampInteger(DateTime dateTime) {
    return 0; // Not used for TCX
  }
}
