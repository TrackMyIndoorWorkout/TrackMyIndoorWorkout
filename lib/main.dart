import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'virtual_velodrome_rider_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(VirtualVelodromeRiderApp());
}
