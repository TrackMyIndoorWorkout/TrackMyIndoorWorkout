import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:isar_community/isar.dart';
import 'package:pref/pref.dart';

import '../../export/export_target.dart';
import '../../export/fit/fit_export.dart';
import '../../persistence/activity.dart';
import '../../persistence/db_utils.dart';
import '../secure_token_storage.dart';
import '../upload_service.dart';
import 'constants.dart';

class DreeveService implements UploadService {
  final http.Client _client;

  DreeveService({http.Client? client}) : _client = client ?? http.Client();

  static String getServerUrl() {
    if (Get.isRegistered<BasePrefService>()) {
      final prefService = Get.find<BasePrefService>();
      final url = prefService.get<String>(dreeveServerUrlTag);
      if (url != null && url.trim().isNotEmpty) {
        return normalizeUrl(url);
      }
    }
    return dreeveDefaultServerUrl;
  }

  static String normalizeUrl(String rawUrl) {
    var url = rawUrl.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  Future<String?> getApiKey() async {
    return await SecureTokenStorage.resolve().read(dreeveApiKeyTag);
  }

  Future<void> saveCredentials(String serverUrl, String apiKey) async {
    final normalized = normalizeUrl(serverUrl);
    if (Get.isRegistered<BasePrefService>()) {
      final prefService = Get.find<BasePrefService>();
      await prefService.set<String>(dreeveServerUrlTag, normalized);
    }
    await SecureTokenStorage.resolve().write(dreeveApiKeyTag, apiKey.trim());
  }

  Future<bool> testConnection(String serverUrl, String apiKey) async {
    final normalized = normalizeUrl(serverUrl);
    final key = apiKey.trim();
    if (key.isEmpty) return false;

    try {
      final uri = Uri.parse('$normalized$dreeveStatusEndpoint');
      final response = await _client.get(
        uri,
        headers: {'Authorization': 'Bearer $key', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['canUpload'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Dreeve testConnection failed: $e');
      return false;
    }
  }

  @override
  Future<bool> hasValidToken() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  @override
  Future<bool> login() async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return false;
    }
    final serverUrl = getServerUrl();
    return await testConnection(serverUrl, apiKey);
  }

  @override
  Future<int> logout() async {
    await SecureTokenStorage.resolve().delete(dreeveApiKeyTag);
    return 200;
  }

  @override
  Future<int> upload(Activity activity, bool calculateGps, [bool virtualWorkout = false]) async {
    if (!DbUtils().hasRecords(activity.id)) {
      return 400;
    }

    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return 401;
    }

    final serverUrl = getServerUrl();
    final exporter = FitExport();
    // Dreeve requires uncompressed .fit files named *.fit
    final fitBytes = await exporter.getExport(
      activity,
      false,
      calculateGps,
      false,
      ExportTarget.regular,
      null,
      virtualWorkout,
    );

    try {
      final uri = Uri.parse('$serverUrl$dreeveUploadEndpoint');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $apiKey';
      request.headers['Accept'] = 'application/json';

      final filename = '${activity.getFileNameStub()}.fit';
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fitBytes,
          filename: filename,
          contentType: MediaType('application', 'octet-stream'),
        ),
      );

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      // Dreeve returns 202 Accepted on success
      if (response.statusCode == 202 || response.statusCode == 200) {
        activity.markDreeveUploaded();
        if (Get.isRegistered<Isar>()) {
          final database = Get.find<Isar>();
          database.writeTxnSync(() {
            database.activitys.putSync(activity);
          });
        }
        return 200;
      }

      debugPrint('Dreeve upload returned ${response.statusCode}: ${response.body}');
      return response.statusCode;
    } catch (e) {
      debugPrint('Dreeve upload failed: $e');
      return 500;
    }
  }
}
