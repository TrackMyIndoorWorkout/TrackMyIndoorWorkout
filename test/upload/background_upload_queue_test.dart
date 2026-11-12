import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_my_indoor_exercise/upload/background/upload_queue.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BackgroundUploadQueue tests', () {
    test('starts empty', () async {
      final queue = BackgroundUploadQueue();
      expect(await queue.getItems(), isEmpty);
      expect(await queue.hasPendingUploads(), isFalse);
    });

    test('enqueues items and prevents duplicates', () async {
      final queue = BackgroundUploadQueue();
      await queue.enqueue(101, "Strava", calculateGps: true);
      await queue.enqueue(102, "Dreeve", calculateGps: false);

      var items = await queue.getItems();
      expect(items.length, equals(2));
      expect(items[0].activityId, equals(101));
      expect(items[0].portalName, equals("Strava"));
      expect(items[0].calculateGps, isTrue);

      expect(items[1].activityId, equals(102));
      expect(items[1].portalName, equals("Dreeve"));
      expect(items[1].calculateGps, isFalse);

      // Re-enqueuing 101 with different GPS setting updates existing item, doesn't duplicate
      await queue.enqueue(101, "Strava", calculateGps: false);
      items = await queue.getItems();
      expect(items.length, equals(2));
      expect(items[0].calculateGps, isFalse);
    });

    test('dequeues specific item', () async {
      final queue = BackgroundUploadQueue();
      await queue.enqueue(101, "Strava");
      await queue.enqueue(101, "Dreeve");
      await queue.enqueue(102, "Strava");

      expect((await queue.getItems()).length, equals(3));

      await queue.dequeue(101, "Strava");
      final remaining = await queue.getItems();
      expect(remaining.length, equals(2));
      expect(remaining.any((i) => i.activityId == 101 && i.portalName == "Strava"), isFalse);
      expect(remaining.any((i) => i.activityId == 101 && i.portalName == "Dreeve"), isTrue);
    });

    test('recordAttempt increments attempts and logs error', () async {
      final queue = BackgroundUploadQueue();
      await queue.enqueue(101, "Strava");

      await queue.recordAttempt(101, "Strava", "Connection timeout");
      var items = await queue.getItems();
      expect(items.first.attempts, equals(1));
      expect(items.first.lastError, equals("Connection timeout"));

      await queue.recordAttempt(101, "Strava", "HTTP 500");
      items = await queue.getItems();
      expect(items.first.attempts, equals(2));
      expect(items.first.lastError, equals("HTTP 500"));
    });

    test('clear wipes all items', () async {
      final queue = BackgroundUploadQueue();
      await queue.enqueue(101, "Strava");
      await queue.enqueue(102, "Dreeve");
      expect(await queue.hasPendingUploads(), isTrue);

      await queue.clear();
      expect(await queue.getItems(), isEmpty);
      expect(await queue.hasPendingUploads(), isFalse);
    });
  });
}
