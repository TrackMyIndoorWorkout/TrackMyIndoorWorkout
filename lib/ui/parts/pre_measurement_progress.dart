import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../models/overlay_state.dart';

class PreMeasurementProgress extends StatefulWidget {
  final String phase;
  final int hundredTime;
  late final int progressTimerGap;
  late final double progressIncrement;

  PreMeasurementProgress({super.key, required this.phase, required this.hundredTime}) {
    const flutterFrameMs = 60;
    if (hundredTime < 100 * flutterFrameMs) {
      progressTimerGap = flutterFrameMs;
      progressIncrement = flutterFrameMs / hundredTime;
    } else {
      progressTimerGap = hundredTime ~/ 100;
      progressIncrement = 0.01;
    }
  }

  @override
  PreMeasurementProgressState createState() => PreMeasurementProgressState();
}

class PreMeasurementProgressState extends State<PreMeasurementProgress> {
  double _progressValue = 0.0;
  double _sizeDefault = 10.0;
  Timer? _timer;

  TextStyle _textStyle = const TextStyle();

  void increaseProgress(double progress) {
    setState(() {
      _progressValue += progress;
      if (_progressValue > 1.0) {
        _progressValue -= 1.0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _sizeDefault = Get.textTheme.displayMedium!.fontSize!;
    _textStyle = Get.textTheme.headlineMedium!;
    Get.put<ProgressState>(ProgressState(progressVisible: true));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(Duration(milliseconds: widget.progressTimerGap), (_) {
        increaseProgress(widget.progressIncrement);
      });
    });
  }

  @override
  void dispose() {
    final progressState = Get.find<ProgressState>();
    progressState.progressVisible = false;
    Get.put<ProgressState>(progressState);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: true,
        progressIndicator: SizedBox(
          height: _sizeDefault * 2,
          width: _sizeDefault * 2,
          child: CircularProgressIndicator(
            strokeWidth: _sizeDefault,
            value: _progressValue,
          ),
        ),
        child: Text(widget.phase, style: _textStyle),
      ),
    );
  }
}

Future<dynamic> progressBottomSheet(String phase, int hundredTime) {
  return Get.bottomSheet(
    Column(
      children: [
        Expanded(
          child: Center(
            child: PreMeasurementProgress(phase: phase, hundredTime: hundredTime),
          ),
        ),
      ],
    ),
  );
}
