import 'dart:async';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../devices/gadgets/cadence_monitor_internal.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class CadenceMonitorPairingBottomSheet extends StatefulWidget {
  const CadenceMonitorPairingBottomSheet({super.key});

  @override
  CadenceMonitorPairingBottomSheetState createState() => CadenceMonitorPairingBottomSheetState();
}

class CadenceMonitorPairingBottomSheetState extends State<CadenceMonitorPairingBottomSheet> {
  static const String tag = "CADENCE_PAIRING";

  final ThemeManager _themeManager = Get.find<ThemeManager>();
  DeviceInternalMotion? _internalMotion;
  TextStyle _captionStyle = const TextStyle();
  TextStyle _subtitleStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _captionStyle = Get.textTheme.bodySmall!.apply(fontSizeFactor: fontSizeFactor);
    _subtitleStyle = _captionStyle.apply(fontFamily: fontFamily);

    if (Get.isRegistered<DeviceInternalMotion>()) {
      _internalMotion = Get.find<DeviceInternalMotion>();
    }
  }

  Future<void> _selectMode(String sport) async {
    if (_internalMotion != null) {
      await _internalMotion!.detach();
      await _internalMotion!.disconnect();
      _internalMotion = null;
      if (Get.isRegistered<DeviceInternalMotion>()) {
        await Get.delete<DeviceInternalMotion>(force: true);
      }
    }

    final newSensor = DeviceInternalMotion(targetSport: sport);
    await newSensor.connect();
    // No discover needed really, but good practice
    await newSensor.discover();

    Get.put<DeviceInternalMotion>(newSensor, permanent: true);

    setState(() {
      _internalMotion = newSensor;
    });
  }

  Future<void> _disconnect() async {
    if (_internalMotion != null) {
      await _internalMotion!.detach();
      await _internalMotion!.disconnect();
      if (Get.isRegistered<DeviceInternalMotion>()) {
        await Get.delete<DeviceInternalMotion>(force: true);
      }
      setState(() {
        _internalMotion = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          if (_internalMotion != null)
            Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sensors),
                  title: TextOneLine(
                    "Internal Motion Sensor",
                    style: _themeManager.boldStyle(_captionStyle, fontSizeFactor: fontSizeFactor),
                  ),
                  subtitle: Text(
                    "Mode: ${_getModeName(_internalMotion!.targetSport)}",
                    style: _subtitleStyle,
                  ),
                  trailing: _themeManager.getGreenFab(Icons.close, _disconnect),
                ),
                const Divider(),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Select Motion Sensor Mode",
              style: _themeManager.boldStyle(_captionStyle, fontSizeFactor: 1.1),
            ),
          ),

          _buildOption(
            icon: Icons.directions_bike,
            title: "Cycling Cadence (RPM)",
            sport: ActivityType.ride,
          ),
          _buildOption(
            icon: Icons.directions_run,
            title: "Running Cadence (SPM)",
            sport: ActivityType.run,
          ),
          _buildOption(
            icon: Icons.rowing,
            title: "Rowing Cadence (SPM)",
            sport: ActivityType.rowing,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _themeManager.getBlueFab(Icons.clear, () => Get.back(result: true)),
    );
  }

  String _getModeName(String sport) {
    switch (sport) {
      case ActivityType.ride:
        return "Cycling (RPM)";
      case ActivityType.run:
        return "Running (SPM)";
      case ActivityType.rowing:
        return "Rowing (SPM)";
      default:
        return sport;
    }
  }

  Widget _buildOption({required IconData icon, required String title, required String sport}) {
    final isSelected = _internalMotion?.targetSport == sport;
    return ListTile(
      leading: Icon(icon, color: isSelected ? _themeManager.getProtagonistColor() : null),
      title: Text(
        title,
        style: isSelected ? _themeManager.boldStyle(_captionStyle) : _captionStyle,
      ),
      onTap: () => _selectMode(sport),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : _themeManager.getBlueFab(Icons.add, () => _selectMode(sport)),
    );
  }
}
