import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:preferences/preference_service.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../persistence/preferences.dart';
import 'common.dart';
import 'heart_rate_monitor_scan_result.dart';

class HeartRateMonitorPairingBottomSheet extends StatefulWidget {
  @override
  _HeartRateMonitorPairingBottomSheetState createState() =>
      _HeartRateMonitorPairingBottomSheetState();
}

class _HeartRateMonitorPairingBottomSheetState extends State<HeartRateMonitorPairingBottomSheet> {
  int _scanDuration;
  TextStyle _adjustedCaptionStyle;
  TextStyle _subtitleStyle;
  List<String> _scanResults;

  @override
  dispose() {
    FlutterBlue.instance.stopScan();
    super.dispose();
  }

  startScan() {
    setState(() {
      _scanResults.clear();
    });
    FlutterBlue.instance.startScan(timeout: Duration(seconds: _scanDuration));
  }

  @override
  initState() {
    initializeDateFormatting();
    super.initState();
    _scanResults = [];
    _scanDuration = PrefService.getInt(SCAN_DURATION_TAG);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_adjustedCaptionStyle == null) {
      _adjustedCaptionStyle =
          Theme.of(context).textTheme.caption.apply(fontSizeFactor: FONT_SIZE_FACTOR);
      _subtitleStyle = _adjustedCaptionStyle.apply(fontFamily: FONT_FAMILY);
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => startScan(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .where((h) =>
                          _scanResults.contains(h.id.id) ||
                          (Get.isRegistered<HeartRateMonitor>() &&
                              Get.find<HeartRateMonitor>()?.device?.id?.id == h.id.id))
                      .map((d) {
                    return ListTile(
                      title: TextOneLine(
                        d.name,
                        overflow: TextOverflow.ellipsis,
                        style: standOutStyle(
                          _adjustedCaptionStyle,
                          FONT_SIZE_FACTOR,
                        ),
                      ),
                      subtitle: Text(d.id.id, style: _subtitleStyle),
                      trailing: StreamBuilder<BluetoothDeviceState>(
                        stream: d.state,
                        initialData: BluetoothDeviceState.disconnected,
                        builder: (c, snapshot) {
                          if (snapshot.data == BluetoothDeviceState.connected) {
                            return FloatingActionButton(
                                heroTag: null,
                                child: Icon(Icons.favorite),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                onPressed: () {
                                  Get.snackbar("Info", "Already connected");
                                });
                          } else {
                            return Text(snapshot.data.toString());
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                    children: snapshot.data.where((d) => d.isWorthy()).map((r) {
                  _scanResults.add(r.device.id.id);
                  return HeartRateMonitorScanResultTile(result: r);
                }).toList()),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.clear),
        onPressed: () => Get.back(result: true),
      ),
    );
  }
}
