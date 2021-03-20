import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:preferences/preference_service.dart';
import '../persistence/mpower_importer.dart';
import '../persistence/preferences.dart';
import '../utils/constants.dart';

typedef void SetProgress(double progress);

class ImportForm extends StatefulWidget {
  @override
  _ImportFormState createState() => _ImportFormState();
}

class _ImportFormState extends State<ImportForm> {
  final dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  GlobalKey<FormState> _formKey;
  String _filePath;
  DateTime _activityDateTime;
  bool _isLoading;
  double _progressValue;
  double _mediaWidth;
  TextEditingController _textController;

  @override
  initState() {
    super.initState();
    _isLoading = false;
    _formKey = GlobalKey<FormState>();
    _progressValue = 0;
    _textController = TextEditingController();
  }

  setProgress(double progress) {
    setState(() {
      _progressValue = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = Get.mediaQuery.size.width;
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('MPower Workout Import'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        progressIndicator: SizedBox(
          child: CircularProgressIndicator(
            strokeWidth: _mediaWidth / 4,
            value: _progressValue,
          ),
          height: _mediaWidth / 2,
          width: _mediaWidth / 2,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'MPower CSV File URL',
                  hintText: 'Paste the CSV file URL',
                  suffixIcon: ElevatedButton(
                    child: Text(
                      '⋯',
                      style: TextStyle(fontSize: 30),
                    ),
                    onPressed: () async {
                      FilePickerResult result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        _textController.text = result.files.single.path;
                      }
                    },
                  ),
                ),
                controller: _textController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please pick a file';
                  }
                  setState(() {
                    _filePath = value;
                  });
                  return null;
                },
              ),
              SizedBox(height: 24),
              DateTimeField(
                format: dateTimeFormat,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.access_time),
                  labelText: 'Workout Date & Time',
                  hintText: 'Pick date & time',
                ),
                onShowPicker: (context, currentValue) async {
                  final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                    );
                    return DateTimeField.combine(date, time);
                  } else {
                    return currentValue;
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please pick a date and time';
                  }
                  setState(() {
                    _activityDateTime = value;
                  });
                  return null;
                },
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            File file = File(_filePath);
                            String contents = await file.readAsString();
                            final importer = MPowerEchelon2Importer(
                                start: _activityDateTime,
                                throttlePercentString: PrefService.getString(THROTTLE_POWER_TAG));
                            var activity = await importer.import(contents, setProgress);
                            setState(() {
                              _isLoading = false;
                            });
                            if (activity != null) {
                              Get.snackbar("Success", "Workout imported!");
                            } else {
                              Get.snackbar(
                                  "Failure", "Problem while importing: ${importer.message}");
                            }
                          } catch (e, callStack) {
                            setState(() {
                              _isLoading = false;
                            });
                            Get.snackbar("Error", "Import unsuccessful: ${e.message}");
                            debugPrintStack(stackTrace: callStack);
                          }
                        } else {
                          Get.snackbar("Error", "Please correct form fields");
                        }
                      },
                      child: Text('Import'),
                    ),
                  ),
                  Expanded(child: Container()),
                  ElevatedButton(
                    child: Text('Reset'),
                    onPressed: () => _formKey.currentState.reset(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
