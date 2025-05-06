// file_manager.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:peshoo_scanner/models/barcode_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class FileManager {
  Future<String?> askUserForDirectory() async {
    return await FilePicker.platform.getDirectoryPath();
  }

  Future<void> exportToExcel(
      BuildContext context,
      Map<String, BarcodeScanData> scannedData,
      String? savedDirectoryPath) async {
    var excelFile = excel.Excel.createExcel();
    excel.Sheet sheetObject = excelFile['Sheet1'];

    sheetObject.appendRow(['Barcode', 'Count']);
    scannedData.forEach((key, value) {
      sheetObject.appendRow([key, value.count]);
    });

    try {
      final path = '$savedDirectoryPath/codes/peshoo_data_${Uuid().v4()}.xlsx';
      final file = File(path);
      if (!(await file.exists())) {
        await file.create(recursive: true);
      }
      await file.writeAsBytes(excelFile.encode()!);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Data exported to $path')));
      OpenFile.open(path);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save file: $e')));
    }
  }

  Future<void> loadSavedDirectory(BuildContext context,
      {required Function(String?) onUpdate}) async {
    final prefs = await SharedPreferences.getInstance();
    String? savedDirectoryPath = prefs.getString('export_path');
    if (savedDirectoryPath == null) {
      final directory = await askUserForDirectory();
      if (directory != null) {
        onUpdate(directory);
        await prefs.setString('export_path', directory);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('The save path has been updated to $directory')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter the save path first.')));
      }
    } else {
      onUpdate(savedDirectoryPath);
    }
  }
}
