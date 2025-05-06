import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:peshoo_scanner/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/audio_helper.dart';
import '../helpers/file_manager.dart';
import '../helpers/permission_helper.dart';
import '../models/barcode_data.dart';
import '../providers/barcode_provider.dart';
import '../widgets/barcode_data_table.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/manual_entry_component.dart';
import '../widgets/scanner_component.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  ScannerScreenState createState() => ScannerScreenState();
}

class ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController manualCodeController = TextEditingController();
  final FocusNode manualCodeFocusNode = FocusNode();
  bool showBorder = false;
  String? savedDirectoryPath;
  bool isScanning = false;

  final AudioHelper audioHelper = AudioHelper();
  final PermissionHelper permissionHelper = PermissionHelper();
  final FileManager fileManager = FileManager();

  @override
  void initState() {
    super.initState();
    audioHelper.preloadSound();
    fileManager.loadSavedDirectory(context, onUpdate: (path) {
      setState(() {
        savedDirectoryPath = path;
      });
    });
  }

  void onDetect(BarcodeCapture capture) async {
    if (isScanning) return;
    isScanning = true;
    final String code = capture.barcodes.first.rawValue ?? '---';
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scanDataProvider =
        Provider.of<ScanDataProvider>(context, listen: false);
    scanDataProvider.saveScanData(BarcodeScanData(
        userId: authProvider.user!.uid,
        code: code,
        date: DateTime.now(),
        count: 1));
    setState(() {
      context.read<BarcodeProvider>().addBarcode(context, code);
      showBorder = true;
    });
    audioHelper.playSound();
    await Future.delayed(Duration(milliseconds: 600));
    setState(() {
      showBorder = false;
    });
    await Future.delayed(Duration(milliseconds: 600));
    isScanning = false;
  }

  void askUserForDirectory() async {
    final directory = await fileManager.askUserForDirectory();
    if (directory != null) {
      setState(() {
        savedDirectoryPath = directory;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save path updated to $directory')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a save path.')));
    }
  }

  void exportToExcel() async {
    await permissionHelper.checkStoragePermission(context);
    if (savedDirectoryPath != null) {
      final barcodeProvider =
          Provider.of<BarcodeProvider>(context, listen: false);
      final scanData = barcodeProvider.scannedData;
      fileManager.exportToExcel(context, scanData, savedDirectoryPath);
    }
  }

  void addManualCode() {
    final String code = manualCodeController.text.trim();
    if (code.isNotEmpty) {
      audioHelper.playSound();
      context.read<BarcodeProvider>().addBarcode(context, code);
      manualCodeController.clear();
      manualCodeFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        body: Stack(children: [
          Column(children: [
            ScannerComponent(onDetect: onDetect, showBorder: showBorder),
            ManualEntryComponent(
                controller: manualCodeController,
                focusNode: manualCodeFocusNode,
                onSubmit: addManualCode),
            BarcodeDataTable()
          ]),
          Positioned(
              right: 20,
              bottom: 20,
              child: ElevatedButton(
                  onLongPress: askUserForDirectory,
                  onPressed: exportToExcel,
                  child: Icon(Icons.save)))
        ]));
  }
}
