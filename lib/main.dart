import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'track_my_indoor_exercise_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(TrackMyIndoorExerciseApp());
}
