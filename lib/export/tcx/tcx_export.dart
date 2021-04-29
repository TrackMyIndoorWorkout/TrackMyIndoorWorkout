import 'dart:convert';
import 'dart:math';

import '../../persistence/preferences.dart';
import '../../utils/display.dart';
import '../activity_export.dart';
import '../export_model.dart';
import '../export_record.dart';

class TCXExport extends ActivityExport {
  StringBuffer _sb;

  TCXExport() : super(nonCompressedFileExtension: 'tcx', nonCompressedMimeType: 'text/xml') {
    _sb = StringBuffer();
  }

  Future<List<int>> getFileCore(ExportModel exportModel) async {
    // The prolog of the TCX file
    _sb.write("""<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase
    xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd"
    xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1"
    xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2"
    xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2"
    xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns4="http://www.garmin.com/xmlschemas/ProfileExtension/v1">""");

    addActivity(exportModel);
    addAuthor(exportModel);

    _sb.write("</TrainingCenterDatabase>\n");

    return utf8.encode(_sb.toString());
  }

  void addActivity(ExportModel exportModel) {
    final activityType = tcxSport(exportModel.sport);
    // Add Activity
    //-------------
    _sb.write("""  <Activities>
    <Activity Sport="$activityType">\n""");

    // Add ID
    addElement('Id', timeStampString(exportModel.dateActivity));
    addLap(exportModel);
    addCreator(exportModel);

    _sb.write("    </Activity>\n");
    _sb.write("  </Activities>\n");
  }

  void addLap(ExportModel exportModel) {
    // Add lap
    //---------
    _sb.write('        <Lap StartTime="${timeStampString(exportModel.dateActivity)}">\n');

    addElement('TotalTimeSeconds', exportModel.totalTime.toString());
    // Add Total distance in meters
    addElement('DistanceMeters', exportModel.totalDistance.toStringAsFixed(2));

    // Add Maximum speed in meter/second
    addElement('MaximumSpeed', exportModel.maximumSpeed.toStringAsFixed(2));

    if ((exportModel.averageHeartRate ?? 0) > 0) {
      addElement('AverageHeartRateBpm', exportModel.averageHeartRate.toStringAsFixed(2));
    }
    if ((exportModel.maximumHeartRate ?? 0) > 0) {
      addElement('MaximumHeartRateBpm', exportModel.maximumHeartRate.toString());
    }
    if ((exportModel.averageCadence ?? 0) > 0) {
      final cadence = min(max(exportModel.averageCadence, 0), 254).toInt();
      addElement('Cadence', cadence.toStringAsFixed(2));
    }

    // Add calories
    addElement('Calories', exportModel.calories.toString());
    // Add intensity (what is the meaning?)
    addElement('Intensity', 'Active');
    // Add intensity (what is the meaning?)
    addElement('TriggerMethod', 'Manual');

    addTrack(exportModel);

    _sb.write('        </Lap>\n');
  }

  void addTrack(ExportModel exportModel) {
    _sb.write('          <Track>\n');

    // Add track inside the lap
    for (var record in exportModel.records) {
      addTrackPoint(record);
    }

    _sb.write('          </Track>\n');
  }

  /// Generate a string that will include
  /// all the tags corresponding to TCX trackpoint
  ///
  /// Extension handling is missing for the moment
  ///
  void addTrackPoint(ExportRecord record) {
    _sb.write("<Trackpoint>\n");
    addElement('Time', record.timeStampString);
    addPosition(record.latitude.toStringAsFixed(10), record.longitude.toStringAsFixed(10));
    addElement('AltitudeMeters', record.altitude.toString());
    addElement('DistanceMeters', record.distance.toStringAsFixed(2));
    if (record.cadence != null) {
      final cadence = min(max(record.cadence, 0), 254).toInt();
      addElement('Cadence', cadence.toString());
    }

    addExtensions('Speed', record.speed.toStringAsFixed(2), 'Watts', record.power);

    if (record.heartRate != null &&
        (record.heartRate > 0 ||
            heartRateGapWorkaround == DATA_GAP_WORKAROUND_NO_WORKAROUND ||
            heartRateLimitingMethod == HEART_RATE_LIMITING_WRITE_ZERO)) {
      addHeartRate(record.heartRate);
    }

    _sb.write("</Trackpoint>\n");
  }

  void addCreator(ExportModel exportModel) {
    _sb.write("""    <Creator xsi:type="Device_t">
      <Name>${exportModel.descriptor.fullName}</Name>
      <UnitId>${exportModel.deviceId}</UnitId>
      <ProductID>${exportModel.descriptor.modelName}</ProductID>
      <Version>
        <VersionMajor>${exportModel.versionMajor}</VersionMajor>
        <VersionMinor>${exportModel.versionMinor}</VersionMinor>
        <BuildMajor>${exportModel.buildMajor}</BuildMajor>
        <BuildMinor>${exportModel.buildMinor}</BuildMinor>
      </Version>
    </Creator>\n""");
  }

  void addAuthor(ExportModel exportModel) {
    _sb.write("""  <Author xsi:type="Application_t">
    <Name>${exportModel.author}</Name>
    <Build>
      <Version>
        <VersionMajor>${exportModel.versionMajor}</VersionMajor>
        <VersionMinor>${exportModel.versionMinor}</VersionMinor>
        <BuildMajor>${exportModel.buildMajor}</BuildMajor>
        <BuildMinor>${exportModel.buildMinor}</BuildMinor>
      </Version>
    </Build>
    <LangID>${exportModel.langID}</LangID>
    <PartNumber>${exportModel.partNumber}</PartNumber>
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
  String timeStampString(DateTime dateTime) {
    return dateTime.toUtc().toString().replaceFirst(' ', 'T');
  }

  int timeStampInteger(DateTime dateTime) {
    return 0; // Not used for TCX
  }
}
