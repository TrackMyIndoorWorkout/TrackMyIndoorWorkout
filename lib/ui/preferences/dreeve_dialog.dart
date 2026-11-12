import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../upload/constants.dart';
import '../../upload/dreeve/dreeve_service.dart';
import '../../upload/upload_service.dart';
import '../../utils/theme_manager.dart';

class DreeveConfigDialog extends StatefulWidget {
  final VoidCallback? onSaved;

  const DreeveConfigDialog({super.key, this.onSaved});

  static Future<void> show(BuildContext context, {VoidCallback? onSaved}) async {
    await showDialog(
      context: context,
      builder: (context) => DreeveConfigDialog(onSaved: onSaved),
    );
  }

  @override
  State<DreeveConfigDialog> createState() => _DreeveConfigDialogState();
}

class _DreeveConfigDialogState extends State<DreeveConfigDialog> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _obscureApiKey = true;
  String? _errorMessage;
  final DreeveService _dreeveService = UploadService.getInstance(dreeveChoice) as DreeveService;

  @override
  void initState() {
    super.initState();
    _urlController.text = DreeveService.getServerUrl();
    _loadExistingKey();
  }

  Future<void> _loadExistingKey() async {
    final key = await _dreeveService.getApiKey();
    if (key != null && mounted) {
      setState(() {
        _apiKeyController.text = key;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testAndSave() async {
    final url = _urlController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (url.isEmpty) {
      setState(() {
        _errorMessage = "Server URL cannot be empty";
      });
      return;
    }
    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = "API Key cannot be empty";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await _dreeveService.testConnection(url, apiKey);
    if (!mounted) return;

    if (success) {
      await _dreeveService.saveCredentials(url, apiKey);
      widget.onSaved?.call();
      Get.back();
      Get.snackbar("Dreeve", "Connected successfully!");
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Connection test failed. Check URL and API Key.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Get.find<ThemeManager>();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cloud_upload_outlined, color: themeManager.getDreeveColor()),
          const SizedBox(width: 8),
          const Text("Dreeve Settings"),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Configure your self-hosted or cloud Dreeve instance.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: "Instance URL",
                hintText: "https://app.dreeve.org",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: "API Key",
                hintText: "drv_...",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.key),
                suffixIcon: IconButton(
                  icon: Icon(_obscureApiKey ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
              ),
              obscureText: _obscureApiKey,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: themeManager.getRedColor(), fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Get.back(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isLoading ? null : _testAndSave,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Test & Save"),
        ),
      ],
    );
  }
}
