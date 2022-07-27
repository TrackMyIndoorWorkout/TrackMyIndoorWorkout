import 'dart:io';

import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:flutter/widgets.dart';

Future<String> pickDirectory(BuildContext context, String existingPath) async {
  final directory = Directory(existingPath.isEmpty ? FolderPicker.ROOTPATH : existingPath);
  final newDirectory = await FolderPicker.pick(
    allowFolderCreation: true,
    context: context,
    rootDirectory: directory,
  );

  return newDirectory?.path ?? "";
}
