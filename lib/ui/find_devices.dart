import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:preferences/preferences.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';
import '../devices/devices.dart';
import '../persistence/preferences.dart';
import '../strava/strava_service.dart';
import 'activities.dart';
import 'device.dart';
import 'preferences.dart';
import 'scan_result.dart';

const HELP_URL =
    "https://trackmyindoorworkout.github.io/2020/09/25/quick-start.html";

extension DeviceMathing on BluetoothDevice {
  bool seemsSupported() {
    for (var dev in deviceMap.values) {
      if (name.startsWith(dev.namePrefix)) {
        return true;
      }
    }

    return false;
  }
}

class FindDevicesScreen extends StatefulWidget {
  FindDevicesScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FindDevicesState();
  }
}

class FindDevicesState extends State<FindDevicesScreen> {
  bool _filterDevices;

  @override
  dispose() {
    FlutterBlue.instance.stopScan();
    super.dispose();
  }

  @override
  void initState() {
    initializeDateFormatting();
    _filterDevices = PrefService.getBool(DEVICE_FILTERING_TAG);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_filterDevices
            ? 'Supported Exercise Equipment:'
            : 'Bluetooth Devices'),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: FlutterBlue.instance.isScanning,
            initialData: _instantScan,
            builder: (c, snapshot) {
              if (snapshot.data) {
                return JumpingDotsProgressIndicator(
                  fontSize: 30.0,
                  color: Colors.white,
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .where((d) => d.seemsSupported())
                      .map((d) => ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  return RaisedButton(
                                      child: Text('OPEN'),
                                      onPressed: () async {
                                        await FlutterBlue.instance.stopScan();
                                        await Get.to(DeviceScreen(
                                            device: d,
                                            initialState: snapshot.data,
                                            size: Get.mediaQuery.size));
                                      });
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .where(
                          (d) => !_filterDevices || d.device.seemsSupported())
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () async {
                            await FlutterBlue.instance.stopScan();
                            await Get.to(DeviceScreen(
                                device: r.device,
                                initialState: BluetoothDeviceState.disconnected,
                                size: Get.mediaQuery.size));
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FabCircularMenu(
        fabOpenIcon: const Icon(Icons.menu, color: Colors.white),
        fabCloseIcon: const Icon(Icons.close, color: Colors.white),
        children: [
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.help),
            foregroundColor: Colors.lightBlue,
            backgroundColor: Colors.white,
            onPressed: () async {
              if (await canLaunch(HELP_URL)) {
                launch(HELP_URL);
              } else {
                Get.snackbar("Attention", "Cannot open URL");
              }
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(BrandIcons.strava),
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepOrangeAccent,
            onPressed: () async {
              StravaService stravaService;
              if (!Get.isRegistered<StravaService>()) {
                stravaService = Get.put<StravaService>(StravaService());
              } else {
                stravaService = Get.find<StravaService>();
              }
              final success = await stravaService.login();
              if (!success) {
                Get.snackbar("Warning", "Strava login unsuccessful");
              }
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.list_alt),
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            onPressed: () async => Get.to(ActivitiesScreen()),
          ),
          StreamBuilder<bool>(
            stream: FlutterBlue.instance.isScanning,
            initialData: false,
            builder: (c, snapshot) {
              if (snapshot.data) {
                return FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.stop),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.indigo,
                  onPressed: () async => await FlutterBlue.instance.stopScan(),
                );
              } else {
                return FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.search),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  onPressed: () => FlutterBlue.instance
                      .startScan(timeout: Duration(seconds: 4)),
                );
              }
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.settings),
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            onPressed: () async => Get.to(PreferencesScreen()),
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.filter_alt),
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            onPressed: () async {
              Get.defaultDialog(
                title: 'Device filtering',
                middleText: 'Should the app try to filter supported devices? ' +
                    'Yes: filter. No: show all nearby Bluetooth devices',
                confirm: FlatButton(
                  child: Text("Yes"),
                  onPressed: () {
                    PrefService.setBool(DEVICE_FILTERING_TAG, true);
                    setState(() {
                      _filterDevices = true;
                    });
                    Get.close(1);
                  },
                ),
                cancel: FlatButton(
                  child: Text("No"),
                  onPressed: () {
                    PrefService.setBool(DEVICE_FILTERING_TAG, false);
                    setState(() {
                      _filterDevices = false;
                    });
                    Get.close(1);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
