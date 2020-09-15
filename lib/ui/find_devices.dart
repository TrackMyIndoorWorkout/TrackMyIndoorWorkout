import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import '../devices/devices.dart';
import '../persistence/strava_service.dart';
import 'device.dart';
import 'scan_result.dart';

class FindDevicesScreen extends StatelessWidget {
  Widget _alertDialog(BluetoothDevice device, bool connect) {
    return AlertDialog(
      title: Text(devices[0].fullName),
      content: Text('Device does not seem to be a ${devices[0].fullName} ' +
          'by name. Still continue?'),
      actions: <Widget>[
        FlatButton(
          child: Text('Yes'),
          onPressed: () async {
            Get.close(1);
            if (connect) {
              await device.connect();
            }
            await Get.to(DeviceScreen(device: device));
          },
        ),
        FlatButton(child: Text('No'), onPressed: () => Get.close(1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices'),
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
                                        if (d.name.startsWith(
                                            devices[0].namePrefix)) {
                                          await Get.to(DeviceScreen(device: d));
                                        } else {
                                          await Get.dialog(
                                              _alertDialog(d, false),
                                              barrierDismissible: false);
                                        }
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
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () async {
                            if (r.device.name.startsWith("CHRONO")) {
                              await Get.to(DeviceScreen(device: r.device));
                            } else {
                              await Get.dialog(_alertDialog(r.device, false),
                                  barrierDismissible: false);
                            }
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
      floatingActionButton: Row(
        children: [
          FloatingActionButton(
            heroTag: null,
            child: Icon(BrandIcons.strava),
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
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepOrange,
          ),
          StreamBuilder<bool>(
            stream: FlutterBlue.instance.isScanning,
            initialData: false,
            builder: (c, snapshot) {
              if (snapshot.data) {
                return FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.stop),
                  onPressed: () => FlutterBlue.instance.stopScan(),
                );
              } else {
                return FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.search),
                  onPressed: () => FlutterBlue.instance
                      .startScan(timeout: Duration(seconds: 4)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
