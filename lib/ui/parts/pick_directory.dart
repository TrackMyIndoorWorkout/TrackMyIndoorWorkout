import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

Future<String> pickDirectory(BuildContext context, String title, String existingPath) async {
  final initialDir = existingPath.isNotEmpty ? existingPath : null;
  final path =
      await FilePicker.platform.getDirectoryPath(dialogTitle: title, initialDirectory: initialDir);

  return path ?? "";
}
