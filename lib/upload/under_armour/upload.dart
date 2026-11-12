import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';

import '../../export/activity_export.dart';
import '../../persistence/activity.dart';
import 'constants.dart';
import 'under_armour_token.dart';

mixin Upload {
  /// statusCode:
  /// 201 activity created
  /// 400 problem could be that activity already uploaded
  ///
  Future<int> uploadActivity(
    Activity activity,
    List<int> fileContent,
    ActivityExport exporter,
    String clientId,
  ) async {
    debugPrint('Starting to upload activity');

    if (!Get.isRegistered<UnderArmourToken>()) {
      debugPrint('Token not yet known');
      return 401;
    }

    final underArmourToken = Get.find<UnderArmourToken>();
    final headers = underArmourToken.getAuthorizationHeader(clientId);

    if (headers.containsKey('88') == true) {
      debugPrint('Token not yet known');
      return 401;
    }

    headers.addAll({
      "Accept": "application/json",
      "Accept-Encoding": "gzip",
      "Content-Type": "application/json",
      "Content-Encoding": "gzip",
      "Content-Length": fileContent.length.toString(),
    });

    final uploadResponse = await http.post(
      Uri.parse(uploadsEndpoint),
      headers: headers,
      body: fileContent,
    );

    debugPrint('Response: ${uploadResponse.statusCode} ${uploadResponse.reasonPhrase}');

    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      debugPrint('Error while uploading the activity to UnderArmour');
      activity.clearUnderArmourUpload();
      if (Get.isRegistered<Isar>()) {
        final database = Get.find<Isar>();
        database.writeTxnSync(() {
          database.activitys.putSync(activity);
        });
      }
    } else {
      debugPrint('$uploadResponse');
      final responseBody = uploadResponse.body;
      int workoutId = 0;

      // 1. Try structured JSON decoding (HAL or standard map)
      try {
        final dynamic decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('id')) {
            workoutId = int.tryParse(decoded['id'].toString()) ?? 0;
          }
          if (workoutId == 0 && decoded['_links'] is Map<String, dynamic>) {
            final links = decoded['_links'] as Map<String, dynamic>;
            final workoutLinks = links['workout'] ?? links['self'];
            if (workoutLinks is List && workoutLinks.isNotEmpty) {
              final first = workoutLinks.first;
              if (first is Map<String, dynamic>) {
                if (first.containsKey('id')) {
                  workoutId = int.tryParse(first['id'].toString()) ?? 0;
                } else if (first.containsKey('href')) {
                  final match = RegExp(r'/workout/(\d+)').firstMatch(first['href'].toString());
                  if (match != null) {
                    workoutId = int.tryParse(match.group(1)!) ?? 0;
                  }
                }
              }
            } else if (workoutLinks is Map<String, dynamic>) {
              if (workoutLinks.containsKey('id')) {
                workoutId = int.tryParse(workoutLinks['id'].toString()) ?? 0;
              } else if (workoutLinks.containsKey('href')) {
                final match = RegExp(r'/workout/(\d+)').firstMatch(workoutLinks['href'].toString());
                if (match != null) {
                  workoutId = int.tryParse(match.group(1)!) ?? 0;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error parsing UnderArmour response as JSON: $e');
      }

      // 2. Fallback regex matching on the raw response body if JSON structure differs
      if (workoutId == 0) {
        final match = RegExp(r'/v7\.1/workout/(\d+)').firstMatch(responseBody);
        if (match != null) {
          workoutId = int.tryParse(match.group(1)!) ?? 0;
        }
      }

      if (workoutId > 0) {
        debugPrint('UnderArmour workoutId: $workoutId');
        activity.markUnderArmourUploaded(workoutId);
        if (Get.isRegistered<Isar>()) {
          final database = Get.find<Isar>();
          database.writeTxnSync(() {
            database.activitys.putSync(activity);
          });
        }
      } else {
        debugPrint('Could not extract workoutId from UnderArmour response');
      }
    }

    return uploadResponse.statusCode;
  }
}
