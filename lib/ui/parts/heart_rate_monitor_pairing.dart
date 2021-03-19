import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:preferences/preference_service.dart';
import '../../persistence/preferences.dart';
import 'heart_rate_monitor_scan_result.dart';

class HeartRateMonitorPairingBottomSheet extends StatefulWidget {
  @override
  _HeartRateMonitorPairingBottomSheetState createState() =>
      _HeartRateMonitorPairingBottomSheetState();
}

class _HeartRateMonitorPairingBottomSheetState extends State<HeartRateMonitorPairingBottomSheet> {
  int _scanDuration;

  @override
  dispose() {
    FlutterBlue.instance.stopScan();
    super.dispose();
  }

  startScan() {
    FlutterBlue.instance.startScan(timeout: Duration(seconds: _scanDuration));
  }

  @override
  initState() {
    initializeDateFormatting();
    super.initState();
    _scanDuration = PrefService.getInt(SCAN_DURATION_TAG);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => startScan(),
        child: SingleChildScrollView(
          child: StreamBuilder<List<ScanResult>>(
            stream: FlutterBlue.instance.scanResults,
            initialData: [],
            builder: (c, snapshot) => Column(
              children: snapshot.data
                  .where((d) => d.isWorthy())
                  .map((r) => HeartRateMonitorScanResultTile(result: r))
                  .toList(),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.clear),
        onPressed: () => Get.close(1),
      ),
    );
  }
}
