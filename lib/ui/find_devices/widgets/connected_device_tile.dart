import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../devices/bluetooth_device_ex.dart';
import '../../../utils/string_ex.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/constants.dart';

class ConnectedDeviceTile extends StatelessWidget {
  final BluetoothDevice? device;
  final IconData icon;
  final VoidCallback onTap;
  final ThemeManager themeManager;
  final TextStyle captionStyle;
  final TextStyle subtitleStyle;

  const ConnectedDeviceTile({
    super.key,
    required this.device,
    required this.icon,
    required this.onTap,
    required this.themeManager,
    required this.captionStyle,
    required this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (device == null) return Container();

    return ListTile(
      title: TextOneLine(
        device?.nonEmptyName ?? emptyMeasurement,
        overflow: TextOverflow.ellipsis,
        style: themeManager.boldStyle(captionStyle, fontSizeFactor: fontSizeFactor),
      ),
      subtitle: Text(
        device?.remoteId.str.shortAddressString() ?? emptyMeasurement,
        style: subtitleStyle,
      ),
      trailing: themeManager.getGreenFab(icon, onTap),
    );
  }
}
