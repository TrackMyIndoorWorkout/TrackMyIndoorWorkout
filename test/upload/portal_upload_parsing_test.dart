import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/upload/constants.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

void main() {
  group('Activity.clearUpload tests', () {
    test('clearUpload clears TrainingPeaks in-flight state', () {
      final activity = Activity(
        id: 1,
        deviceName: "Bike",
        deviceId: "dev1",
        hrmId: "",
        start: DateTime.now(),
        distance: 100.0,
        elapsed: 10,
        movingTime: 10000,
        calories: 10,
        fourCC: "TEST",
        sport: ActivityType.ride,
        powerFactor: 1.0,
        calorieFactor: 1.0,
        hrCalorieFactor: 1.0,
        hrmCalorieFactor: 1.0,
        hrBasedCalories: false,
        timeZone: "UTC",
      );

      activity.markTrainingPeaksUploading("uuid-1234");
      expect(activity.trainingPeaksFileTrackingUuid, equals("uuid-1234"));
      expect(activity.trainingPeaksUploaded, isFalse);

      activity.markTrainingPeaksUploaded(999);
      expect(activity.trainingPeaksWorkoutId, equals(999));
      expect(activity.trainingPeaksUploaded, isTrue);

      activity.clearUpload(trainingPeaksChoice);
      expect(activity.trainingPeaksFileTrackingUuid, isEmpty);
      expect(activity.trainingPeaksWorkoutId, equals(0));
      expect(activity.trainingPeaksUploaded, isFalse);
    });

    test('clearUpload clears UnderArmour in-flight state', () {
      final activity = Activity(
        id: 2,
        deviceName: "Bike",
        deviceId: "dev2",
        hrmId: "",
        start: DateTime.now(),
        distance: 100.0,
        elapsed: 10,
        movingTime: 10000,
        calories: 10,
        fourCC: "TEST",
        sport: ActivityType.ride,
        powerFactor: 1.0,
        calorieFactor: 1.0,
        hrCalorieFactor: 1.0,
        hrmCalorieFactor: 1.0,
        hrBasedCalories: false,
        timeZone: "UTC",
      );

      activity.markUnderArmourUploaded(8888);
      expect(activity.uaWorkoutId, equals(8888));
      expect(activity.underArmourUploaded, isTrue);

      activity.clearUpload(underArmourChoice);
      expect(activity.uaWorkoutId, equals(0));
      expect(activity.underArmourUploaded, isFalse);
    });

    test('clearUpload clears Suunto, Strava, and Dreeve states', () {
      final activity = Activity(
        id: 3,
        deviceName: "Bike",
        deviceId: "dev3",
        hrmId: "",
        start: DateTime.now(),
        distance: 100.0,
        elapsed: 10,
        movingTime: 10000,
        calories: 10,
        fourCC: "TEST",
        sport: ActivityType.ride,
        powerFactor: 1.0,
        calorieFactor: 1.0,
        hrCalorieFactor: 1.0,
        hrmCalorieFactor: 1.0,
        hrBasedCalories: false,
        timeZone: "UTC",
      );

      activity.markSuuntoUploaded("https://maps.suunto.com/move/123");
      activity.clearUpload(suuntoChoice);
      expect(activity.suuntoUploaded, isFalse);
      expect(activity.suuntoWorkoutUrl, isEmpty);

      activity.uploaded = true;
      activity.stravaActivityId = 777;
      activity.clearUpload(stravaChoice);
      expect(activity.stravaActivityId, equals(0));

      activity.markDreeveUploaded("dreeve-uuid");
      activity.clearUpload(dreeveChoice);
      expect(activity.dreeveUploaded, isFalse);
      expect(activity.dreeveUploadIdentifier, isEmpty);
    });
  });

  group('Response JSON parsing verification', () {
    test('parses TrainingPeaks async status JSON correctly', () {
      const sampleResponse = '''{
        "Completed": true,
        "Status": "Success",
        "WorkoutIds": [54321, 54322]
      }''';

      final dynamic decoded = jsonDecode(sampleResponse);
      expect(decoded is Map<String, dynamic>, isTrue);
      final json = decoded as Map<String, dynamic>;

      final completedVal = json['Completed'] ?? json['completed'];
      final completed = completedVal == true || completedVal?.toString().toLowerCase() == 'true';
      expect(completed, isTrue);

      final rawWorkoutIds = json['WorkoutIds'] ?? json['workoutIds'];
      expect(rawWorkoutIds, isA<List>());
      final workoutIds = (rawWorkoutIds as List)
          .map((id) => int.tryParse(id.toString()))
          .nonNulls
          .toList(growable: false);
      expect(workoutIds, equals([54321, 54322]));
    });

    test('parses UnderArmour HAL link JSON correctly', () {
      const sampleHalResponse = '''{
        "_links": {
          "workout": [
            {
              "href": "/v7.1/workout/987654321/",
              "id": "987654321"
            }
          ]
        }
      }''';

      final dynamic decoded = jsonDecode(sampleHalResponse);
      expect(decoded is Map<String, dynamic>, isTrue);
      final json = decoded as Map<String, dynamic>;

      int workoutId = 0;
      if (json.containsKey('id')) {
        workoutId = int.tryParse(json['id'].toString()) ?? 0;
      }
      if (workoutId == 0 && json['_links'] is Map<String, dynamic>) {
        final links = json['_links'] as Map<String, dynamic>;
        final workoutLinks = links['workout'] ?? links['self'];
        if (workoutLinks is List && workoutLinks.isNotEmpty) {
          final first = workoutLinks.first;
          if (first is Map<String, dynamic>) {
            if (first.containsKey('id')) {
              workoutId = int.tryParse(first['id'].toString()) ?? 0;
            }
          }
        }
      }

      expect(workoutId, equals(987654321));
    });

    test('parses UnderArmour regex fallback correctly', () {
      const sampleRawResponse = '<a href="/v7.1/workout/11223344/">Workout Link</a>';
      final match = RegExp(r'/v7\.1/workout/(\d+)').firstMatch(sampleRawResponse);
      expect(match, isNotNull);
      final workoutId = int.tryParse(match!.group(1)!) ?? 0;
      expect(workoutId, equals(11223344));
    });
  });
}
