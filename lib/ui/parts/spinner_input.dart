import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

import '../../providers/theme_mode.dart';
import '../../utils/theme_manager.dart';

class SpinnerInput extends ConsumerStatefulWidget {
  static const defaultSize = Size(35.0, 35.0);

  final bool disabledPopup;
  final double spinnerValue;
  final double? middleNumberWidth;
  final EdgeInsets middleNumberPadding;
  final TextStyle middleNumberStyle;
  final Color? middleNumberBackground;
  final double minValue;
  final double maxValue;
  final double step;
  final int fractionDigits;
  final Duration longPressSpeed;
  final Function(double newValue)? onChange;
  final bool disabledLongPress;
  final ButtonStyle? plusButtonStyle;
  final Size? plusButtonSize;
  final Widget? plusButtonChild;
  final ButtonStyle? minusButtonStyle;
  final Size? minusButtonSize;
  final Widget? minusButtonChild;
  final ButtonStyle? popupButtonStyle;
  final Size? popupButtonSize;
  final Widget? popupButtonChild;
  final intl.NumberFormat? numberFormat;
  final TextStyle popupTextStyle;
  final TextDirection direction;

  const SpinnerInput({
    super.key,
    required this.spinnerValue,
    this.middleNumberWidth,
    this.middleNumberBackground,
    this.middleNumberPadding = const EdgeInsets.all(5),
    this.middleNumberStyle = const TextStyle(fontSize: 20),
    this.maxValue = 100,
    this.minValue = 0,
    this.step = 1,
    this.fractionDigits = 0,
    this.longPressSpeed = const Duration(milliseconds: 50),
    this.disabledLongPress = false,
    this.disabledPopup = false,
    this.onChange,
    this.plusButtonStyle,
    this.plusButtonSize,
    this.plusButtonChild,
    this.minusButtonStyle,
    this.minusButtonSize,
    this.minusButtonChild,
    this.popupButtonStyle,
    this.popupButtonSize,
    this.popupButtonChild,
    this.numberFormat,
    this.direction = TextDirection.ltr,
    this.popupTextStyle = const TextStyle(fontSize: 18, color: Colors.black87, height: 1.15),
  });

  @override
  SpinnerInputState createState() => SpinnerInputState();
}

class SpinnerInputState extends ConsumerState<SpinnerInput> with TickerProviderStateMixin {
  TextEditingController? textEditingController;
  AnimationController? popupAnimationController;
  final _focusNode = FocusNode();
  final ThemeManager _themeManager = Get.find<ThemeManager>();

  Timer? timer;

  @override
  void initState() {
    // popup text field
    textEditingController = TextEditingController(text: _formatted(widget.spinnerValue));

    // popup animation controller
    popupAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        textEditingController?.selection = TextSelection(
          baseOffset: 0,
          extentOffset: textEditingController?.value.text.length ?? 0,
        );
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    textEditingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    // initialize buttons
    final plusSpinnerSize = widget.plusButtonSize ?? SpinnerInput.defaultSize;
    final plusSpinnerChild = widget.plusButtonChild ?? const Icon(Icons.add);
    final plusSpinnerStyle = widget.plusButtonStyle ??
        ElevatedButton.styleFrom(
          minimumSize: plusSpinnerSize,
          shape: const CircleBorder(),
          foregroundColor: _themeManager.getProtagonistColor(themeMode),
          backgroundColor: _themeManager.getBlueColorInverse(themeMode),
          padding: const EdgeInsets.all(0),
        );

    final minusSpinnerSize = widget.minusButtonSize ?? SpinnerInput.defaultSize;
    final minusSpinnerChild = widget.minusButtonChild ?? const Icon(Icons.remove);
    final minusSpinnerStyle = widget.minusButtonStyle ??
        ElevatedButton.styleFrom(
          minimumSize: minusSpinnerSize,
          shape: const CircleBorder(),
          foregroundColor: _themeManager.getProtagonistColor(themeMode),
          backgroundColor: _themeManager.getBlueColorInverse(themeMode),
          padding: const EdgeInsets.all(0),
        );

    final popupButtonSize = widget.popupButtonSize ?? SpinnerInput.defaultSize;
    final popupButtonChild = widget.popupButtonChild ?? const Icon(Icons.check);
    final popupButtonStyle = widget.popupButtonStyle ??
        ElevatedButton.styleFrom(
          minimumSize: popupButtonSize,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          foregroundColor: _themeManager.getProtagonistColor(themeMode),
          backgroundColor: _themeManager.getGreenColor(themeMode),
          padding: const EdgeInsets.all(1),
        );

    return Directionality(
      textDirection: widget.direction,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: minusSpinnerSize.width,
                height: minusSpinnerSize.height,
                child: GestureDetector(
                  child: ElevatedButton(
                    style: minusSpinnerStyle,
                    onPressed: () {
                      decrease();
                    },
                    child: minusSpinnerChild,
                  ),
                  onLongPress: () {
                    if (widget.disabledLongPress == false) {
                      timer = Timer.periodic(widget.longPressSpeed, (timer) {
                        decrease();
                      });
                    }
                  },
                  onLongPressUp: () {
                    timer?.cancel();
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (!widget.disabledPopup) {
                    if (popupAnimationController!.isDismissed) {
                      popupAnimationController!.forward();
                      _focusNode.requestFocus();
                    } else {
                      popupAnimationController!.reverse();
                    }
                  }
                },
                child: Container(
                  width: widget.middleNumberWidth,
                  padding: widget.middleNumberPadding,
                  color: widget.middleNumberBackground,
                  child: Text(
                    _formatted(widget.spinnerValue),
                    textAlign: TextAlign.center,
                    style: widget.middleNumberStyle,
                  ),
                ),
              ),
              SizedBox(
                width: plusSpinnerSize.width,
                height: plusSpinnerSize.height,
                child: GestureDetector(
                  child: ElevatedButton(
                    style: plusSpinnerStyle,
                    onPressed: () {
                      increase();
                    },
                    child: plusSpinnerChild,
                  ),
                  onLongPress: () {
                    if (widget.disabledLongPress == false) {
                      timer = Timer.periodic(widget.longPressSpeed, (timer) {
                        increase();
                      });
                    }
                  },
                  onLongPressUp: () {
                    timer?.cancel();
                  },
                ),
              ),
            ],
          ),
          if (widget.disabledPopup == false)
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: textFieldPopUp(popupButtonSize, popupButtonChild, popupButtonStyle),
            ),
        ],
      ),
    );
  }

  void increase() {
    double value = widget.spinnerValue;
    value += widget.step;
    if (value <= widget.maxValue) {
      textEditingController?.text = _formatted(value);
      setState(() {
        if (widget.onChange != null) {
          widget.onChange!(value);
        }
      });
    }
  }

  void decrease() {
    double value = widget.spinnerValue;
    value -= widget.step;
    if (value >= widget.minValue) {
      textEditingController?.text = _formatted(value);
      setState(() {
        if (widget.onChange != null) {
          widget.onChange!(value);
        }
      });
    }
  }

  Widget textFieldPopUp(
      Size popupButtonSize, Widget popupButtonChild, ButtonStyle popupButtonStyle) {
    int maxLength = widget.maxValue.toStringAsFixed(widget.fractionDigits).length;
    if (widget.fractionDigits > 0) maxLength += widget.fractionDigits;

    return ScaleTransition(
      scale: CurvedAnimation(
          parent: popupAnimationController!,
          curve: const Interval(0.0, 1.0, curve: Curves.elasticOut)),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: TextField(
                  // inputFormatters: [
                  //   TextInputFormatter.withFunction((oldValue, newValue) {
                  //     if (widget.numberFormat != null) {
                  //       return TextEditingValue(text: );
                  //     }
                  //     return newValue;
                  //   })
                  // ],
                  maxLength: maxLength,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: widget.popupTextStyle,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    border: InputBorder.none,
                  ),
                  controller: textEditingController,
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: popupButtonSize.width,
                  height: popupButtonSize.height,
                  child: ElevatedButton(
                    style: popupButtonStyle,
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      try {
                        double value = widget.numberFormat != null
                            ? widget.numberFormat!
                                .parse(textEditingController?.text ?? "0")
                                .toDouble()
                            : double.parse(textEditingController?.text ?? "0");
                        if (value <= widget.maxValue && value >= widget.minValue) {
                          setState(() {
                            if (widget.onChange != null) {
                              widget.onChange!(value);
                            }
                          });
                        } else {
                          textEditingController?.text = _formatted(widget.spinnerValue);
                        }
                      } catch (e) {
                        textEditingController?.text = _formatted(widget.spinnerValue);
                      }
                      popupAnimationController?.reset();
                    },
                    child: popupButtonChild,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatted(double value) {
    return widget.numberFormat != null
        ? widget.numberFormat!.format(value)
        : value.toStringAsFixed(widget.fractionDigits);
  }
}
