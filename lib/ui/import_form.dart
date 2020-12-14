import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:regexed_validator/regexed_validator.dart';
import '../persistence/mpower_importer.dart';

typedef void SetProgress(double progress);

class ImportForm extends StatefulWidget {
  @override
  _ImportFormState createState() => _ImportFormState();
}

class _ImportFormState extends State<ImportForm> {
  final dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  GlobalKey<FormState> _formKey;
  String _fileUrl;
  DateTime _activityDateTime;
  bool _isLoading;
  double _progressValue;
  double _mediaWidth;

  @override
  initState() {
    super.initState();
    _isLoading = false;
    _formKey = GlobalKey<FormState>();
    _progressValue = 0;
  }

  setProgress(double progress) {
    setState(() {
      _progressValue = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = Get.mediaQuery.size.width;
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > 1e-6) {
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
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.link),
                  labelText: 'MPower CSV File URL',
                  hintText: 'Paste the CSV file URL',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter an URL';
                  }
                  if (!validator.url(value)) {
                    return 'URL does not seem to be valid';
                  }
                  setState(() {
                    _fileUrl = value;
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
                      initialTime: TimeOfDay.fromDateTime(
                          currentValue ?? DateTime.now()),
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
                        if (!await DataConnectionChecker().hasConnection) {
                          Get.snackbar(
                              "Warning", "No data connection detected");
                          return;
                        }
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            final response = await http.get(_fileUrl);
                            if (!response.headers.containsKey("content-type") ||
                                !response.headers["content-type"]
                                    .startsWith("text")) {
                              setState(() {
                                _isLoading = false;
                              });
                              Get.snackbar("Error",
                                  "Content doesn't seem to be text (CSV)");
                              return;
                            }
                            final importer = MPowerEchelon2Importer(
                                start: _activityDateTime);
                            var activity = await importer.import(response.body, setProgress);
                            setState(() {
                              _isLoading = false;
                            });
                            if (activity != null) {
                              Get.snackbar("Success", "Workout imported!");
                            } else {
                              Get.snackbar("Failure",
                                  "Problem while importing: ${importer.message}");
                            }
                          } catch (e, callStack) {
                            setState(() {
                              _isLoading = false;
                            });
                            Get.snackbar(
                                "Error", "Import unsuccessful: ${e.message}");
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
                  RaisedButton(
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
