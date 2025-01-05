import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import '../models/progress_state.dart';

class PreMeasurementProgress extends ConsumerStatefulWidget {
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

class PreMeasurementProgressState extends ConsumerState<PreMeasurementProgress> {
  double _progressValue = 0.0;
  Timer? _timer;
  final ThemeManager _themeManager = Get.find<ThemeManager>();

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
    final progressState = Get.find<ProgressState>();
    progressState.progressCount += 1;
    Get.put<ProgressState>(progressState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(Duration(milliseconds: widget.progressTimerGap), (_) {
        increaseProgress(widget.progressIncrement);
      });
    });
  }

  @override
  void dispose() {
    final progressState = Get.find<ProgressState>();
    progressState.progressCount -= 1;
    Get.put<ProgressState>(progressState);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final sizeDefault = Theme.of(context).textTheme.displayMedium!.fontSize!;
    final textStyle = Theme.of(context).textTheme.headlineMedium!.apply(
          fontFamily: fontFamily,
          color: _themeManager.getProtagonistColor(themeMode),
        );

    return Scaffold(
      body: LoadingOverlay(
        isLoading: true,
        progressIndicator: SizedBox(
          height: sizeDefault * 2,
          width: sizeDefault * 2,
          child: CircularProgressIndicator(
            strokeWidth: sizeDefault,
            value: _progressValue,
          ),
        ),
        child: Text(widget.phase, style: textStyle),
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
