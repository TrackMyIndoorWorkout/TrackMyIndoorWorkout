import 'dart:io';

import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pref/pref.dart';

import '../import/csv_importer.dart';
import '../persistence/workout_summary.dart';
import '../preferences/leaderboard_and_rank.dart';
import '../preferences/log_level.dart';
import '../utils/logging.dart';

typedef SetProgress = void Function(double progress);

class ImportForm extends StatefulWidget {
  final bool migration;

  const ImportForm({super.key, required this.migration});

  @override
  ImportFormState createState() => ImportFormState();
}

class ImportFormState extends State<ImportForm> {
  final dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _filePath;
  DateTime? _activityDateTime;
  bool _isLoading = false;
  double _progressValue = 0.0;
  double _sizeDefault = 10.0;
  final TextEditingController _textController = TextEditingController();
  bool _leaderboardFeature = leaderboardFeatureDefault;

  @override
  void initState() {
    super.initState();
    _sizeDefault = Get.textTheme.displayMedium!.fontSize!;
    final prefService = Get.find<BasePrefService>();
    _leaderboardFeature = prefService.get<bool>(leaderboardFeatureTag) ?? leaderboardFeatureDefault;
  }

  void setProgress(double progress) {
    setState(() {
      _progressValue = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uploadType = widget.migration ? 'Workout Migration' : 'MPower Workout';
    final csvType = widget.migration ? "Migration" : "MPower";
    return Scaffold(
      appBar: AppBar(
        title: Text('$uploadType Import'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        progressIndicator: SizedBox(
          height: _sizeDefault * 2,
          width: _sizeDefault * 2,
          child: CircularProgressIndicator(
            strokeWidth: _sizeDefault,
            value: _progressValue,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  labelText: '$csvType CSV File URL',
                  hintText: 'Paste the CSV file URL',
                  suffixIcon: ElevatedButton(
                    child: const Text(
                      '⋯',
                      style: TextStyle(fontSize: 30),
                    ),
                    onPressed: () async {
                      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
                        allowedFileExtensions: ["csv"],
                        allowedUtiTypes: null,
                        allowedMimeTypes: ['text/csv'],
                      );
                      final filePath = await FlutterDocumentPicker.openDocument(params: params);
                      if (filePath != null) {
                        _textController.text = filePath;
                        setState(() {
                          _filePath = filePath;
                        });
                      }
                      // final result = await FilePicker.platform.pickFiles();
                      // if (result != null && result.files.single.path != null) {
                      //   _textController.text = result.files.single.path!;
                      //   setState(() {
                      //     _filePath = result.files.single.path;
                      //   });
                      // }
                    },
                  ),
                ),
                controller: _textController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please pick a file';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  _filePath = value;
                }),
              ),
              Visibility(
                visible: !widget.migration,
                child: const SizedBox(height: 24),
              ),
              Visibility(
                visible: !widget.migration,
                child: DateTimeField(
                  format: dateTimeFormat,
                  decoration: const InputDecoration(
                    filled: true,
                    prefixIcon: Icon(Icons.access_time),
                    labelText: 'Workout Date & Time',
                    hintText: 'Pick date & time',
                  ),
                  onShowPicker: (context, currentValue) async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1920),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2030),
                    );

                    if (pickedDate == null || !context.mounted) {
                      return currentValue;
                    }

                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                    );
                    return DateTimeField.combine(pickedDate, time);
                  },
                  validator: (value) {
                    if (value == null && !widget.migration) {
                      return 'Please pick a date and time';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {
                    _activityDateTime = value;
                  }),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState == null) {
                          return;
                        }

                        if (_filePath == null) {
                          Get.snackbar("Error", "Please pick a file");
                        }

                        if (_activityDateTime == null && !widget.migration) {
                          Get.snackbar("Error", "Please pick a date and time");
                        }

                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            File file = File(_filePath!);
                            String contents = await file.readAsString();
                            final importer = CSVImporter(_activityDateTime);
                            final activity = await importer.import(contents, setProgress);
                            setState(() {
                              _isLoading = false;
                            });
                            if (activity != null) {
                              Get.snackbar("Success", "Workout imported!");
                              if (_leaderboardFeature) {
                                final deviceDescriptor = activity.deviceDescriptor();
                                final workoutSummary = activity
                                    .getWorkoutSummary(deviceDescriptor.manufacturerNamePart);
                                final database = Get.find<Isar>();
                                database.writeTxnSync(() {
                                  database.workoutSummarys.putSync(workoutSummary);
                                });
                              }
                            } else {
                              Get.snackbar(
                                  "Failure", "Problem while importing: ${importer.message}");
                            }
                          } on Exception catch (e, stack) {
                            setState(() {
                              _isLoading = false;
                            });
                            final prefService = Get.find<BasePrefService>();
                            final logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
                            Logging().logException(logLevel, "IMPORT_FORM", "onPressed",
                                "error during import", e, stack);
                            Get.snackbar("Error", "Import unsuccessful: $e");
                          }
                        } else {
                          Get.snackbar("Error", "Please correct form fields");
                        }
                      },
                      child: const Text('Import'),
                    ),
                  ),
                  Expanded(child: Container()),
                  ElevatedButton(
                    child: const Text('Reset'),
                    onPressed: () => _formKey.currentState?.reset(),
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
