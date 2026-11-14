import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BackgroundUploadItem {
  final int activityId;
  final String portalName;
  final bool calculateGps;
  final bool virtualWorkout;
  final DateTime enqueuedAt;
  int attempts;
  String lastError;

  BackgroundUploadItem({
    required this.activityId,
    required this.portalName,
    this.calculateGps = true,
    this.virtualWorkout = false,
    DateTime? enqueuedAt,
    this.attempts = 0,
    this.lastError = "",
  }) : enqueuedAt = enqueuedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'portalName': portalName,
    'calculateGps': calculateGps,
    'virtualWorkout': virtualWorkout,
    'enqueuedAt': enqueuedAt.toIso8601String(),
    'attempts': attempts,
    'lastError': lastError,
  };

  factory BackgroundUploadItem.fromJson(Map<String, dynamic> json) => BackgroundUploadItem(
    activityId: json['activityId'] as int,
    portalName: json['portalName'] as String,
    calculateGps: json['calculateGps'] as bool? ?? true,
    virtualWorkout: json['virtualWorkout'] as bool? ?? false,
    enqueuedAt: DateTime.tryParse(json['enqueuedAt'] as String? ?? "") ?? DateTime.now(),
    attempts: json['attempts'] as int? ?? 0,
    lastError: json['lastError'] as String? ?? "",
  );
}

class BackgroundUploadQueue {
  static const String queuePrefKey = "background_upload_queue";

  final SharedPreferences? _injectedPrefs;

  BackgroundUploadQueue({SharedPreferences? prefs}) : _injectedPrefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _injectedPrefs ?? await SharedPreferences.getInstance();
  }

  Future<List<BackgroundUploadItem>> getItems() async {
    final prefs = await _getPrefs();
    final rawList = prefs.getStringList(queuePrefKey) ?? [];
    final List<BackgroundUploadItem> items = [];
    for (final raw in rawList) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          items.add(BackgroundUploadItem.fromJson(decoded));
        }
      } catch (_) {}
    }
    return items;
  }

  Future<void> enqueue(
    int activityId,
    String portalName, {
    bool calculateGps = true,
    bool virtualWorkout = false,
  }) async {
    final prefs = await _getPrefs();
    final items = await getItems();

    // Prevent duplicate entries for the same activity and portal
    final existingIndex = items.indexWhere(
      (item) => item.activityId == activityId && item.portalName == portalName,
    );

    if (existingIndex >= 0) {
      items[existingIndex] = BackgroundUploadItem(
        activityId: activityId,
        portalName: portalName,
        calculateGps: calculateGps,
        virtualWorkout: virtualWorkout,
        enqueuedAt: items[existingIndex].enqueuedAt,
        attempts: items[existingIndex].attempts,
        lastError: items[existingIndex].lastError,
      );
    } else {
      items.add(
        BackgroundUploadItem(
          activityId: activityId,
          portalName: portalName,
          calculateGps: calculateGps,
          virtualWorkout: virtualWorkout,
        ),
      );
    }

    await _saveItems(prefs, items);
  }

  Future<void> dequeue(int activityId, String portalName) async {
    final prefs = await _getPrefs();
    final items = await getItems();
    items.removeWhere((item) => item.activityId == activityId && item.portalName == portalName);
    await _saveItems(prefs, items);
  }

  Future<void> recordAttempt(int activityId, String portalName, String error) async {
    final prefs = await _getPrefs();
    final items = await getItems();
    final index = items.indexWhere(
      (item) => item.activityId == activityId && item.portalName == portalName,
    );
    if (index >= 0) {
      items[index].attempts += 1;
      items[index].lastError = error;
      await _saveItems(prefs, items);
    }
  }

  Future<bool> hasPendingUploads() async {
    final items = await getItems();
    return items.isNotEmpty;
  }

  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.remove(queuePrefKey);
  }

  Future<void> _saveItems(SharedPreferences prefs, List<BackgroundUploadItem> items) async {
    final rawList = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(queuePrefKey, rawList);
  }
}
