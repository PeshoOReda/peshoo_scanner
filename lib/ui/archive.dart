// import 'dart:async';
// import 'dart:io';
// import 'package:excel/excel.dart' as excel;
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:open_file/open_file.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:peshoo_scanner/providers/auth_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
//
// import '../providers/barcode_provider.dart';
//
// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});
//
//   @override
//   ScannerScreenState createState() => ScannerScreenState();
// }
//
// class ScannerScreenState extends State<ScannerScreen> {
//   final TextEditingController _manualCodeController = TextEditingController();
//   final FocusNode _manualCodeFocusNode = FocusNode();
//   bool _showBorder = false;
//   String? _savedDirectoryPath;
//   String? lastScannedCode;
//   DateTime? lastScannedTime;
//   bool _isScanning = false;
//   final AudioPlayer _audioPlayer = AudioPlayer();
//
// //  late FirebaseRemoteConfig _remoteConfig;
//
//   @override
//   void initState() {
//     super.initState();
//     // _setupRemoteConfig();
//     _loadSavedDirectory();
//   }
//
//   // void _setupRemoteConfig() async {
//   //   _remoteConfig = FirebaseRemoteConfig.instance;
//   //   await _remoteConfig.setDefaults(<String, dynamic>{
//   //     'welcome_message': 'Welcome to my app!',
//   //   });
//   //   await _fetchRemoteConfig();
//   // }
//
//   // Future<void> _fetchRemoteConfig() async {
//   //   try {
//   //     await _remoteConfig.fetchAndActivate();
//   //   } catch (exception) {
//   //     if (kDebugMode) {
//   //       print('Failed to fetch remote config: $exception');
//   //     }
//   //   }
//   // }
//
//   Future<void> _loadSavedDirectory() async {
//     final prefs = await SharedPreferences.getInstance();
//     _savedDirectoryPath = prefs.getString('export_path');
//     if (_savedDirectoryPath == null) {
//       final directory = await _askUserForDirectory();
//       if (directory != null) {
//         setState(() {
//           _savedDirectoryPath = directory;
//         });
//         await prefs.setString('export_path', directory);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text('The save path has been updated to $directory')),
//           );
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Please enter the save path first.')));
//         }
//       }
//     }
//   }
//
//   Future<String?> _askUserForDirectory() async {
//     return await FilePicker.platform.getDirectoryPath();
//   }
//
//   void _onDetect(BarcodeCapture capture) async {
//     if (_isScanning) return;
//
//     _isScanning = true;
//     final DateTime now = DateTime.now();
//     final String code = capture.barcodes.first.rawValue ?? '---';
//     setState(() {
//       lastScannedCode = code;
//       lastScannedTime = now;
//       _showBorder = true;
//       context.read<BarcodeProvider>().addBarcode(code);
//     });
//     _playSound();
//     // Wait for half a second to show the green border
//     await Future.delayed(Duration(milliseconds: 600));
//     setState(() {
//       _showBorder = false;
//     });
//     await Future.delayed(Duration(milliseconds: 600));
//     _isScanning = false;
//   }
//
//   Future<void> checkStoragePermission() async {
//     if (await Permission.storage.request().isGranted) {
//       if (kDebugMode) {
//         print("Permissions granted.");
//       }
//     } else {
//       if (kDebugMode) {
//         print("Permissions denied. Please enable storage access.");
//       }
//       if (mounted) {
//         showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                   title: Text('Permissions required'),
//                   content: Text('Please grant storage access to save files.'),
//                   actions: <Widget>[
//                     TextButton(
//                         child: Text('OK'),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         })
//                   ]);
//             });
//       }
//     }
//   }
//
//   void _exportToExcel() async {
//     await checkStoragePermission();
//     if (_savedDirectoryPath == null && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Please enter the save path first.')));
//       return;
//     }
//     var excelFile = excel.Excel.createExcel();
//     excel.Sheet sheetObject = excelFile['Sheet1'];
//     sheetObject.appendRow(['Barcode', 'Count']);
//     if (mounted) {
//       context.read<BarcodeProvider>().scannedData.forEach((key, value) {
//         sheetObject.appendRow([key, value.count.toString()]);
//       });
//     }
//     try {
//       final path = '$_savedDirectoryPath/codes/peshoo_data_${Uuid().v4()}.xlsx';
//       final file = File(path);
//       if (!(await file.exists())) {
//         await file.create(recursive: true);
//       }
//       await file.writeAsBytes(excelFile.encode()!);
//       if (!mounted) return;
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Data exported to $path')));
//       OpenFile.open(path);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to save file: $e')));
//     }
//   }
//
//   void _addManualCode() {
//     final String code = _manualCodeController.text.trim();
//     if (code.isNotEmpty) {
//       _playSound();
//       context.read<BarcodeProvider>().addBarcode(code);
//       _manualCodeController.clear();
//       _manualCodeFocusNode.requestFocus();
//     }
//   }
//
//   void _playSound() async {
//     try {
//       await _audioPlayer.setAsset('assets/vice_city_select.mp3');
//       _audioPlayer.play();
//       Timer(Duration(milliseconds: 600), () {
//         _audioPlayer.stop();
//       });
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error loading audio asset: $e');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//             title: Text('👻SmartCoOde🍀',
//                 style: TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.w900)),
//             backgroundColor: Colors.indigo,
//             actions: [
//               IconButton(
//                 icon: Icon(
//                   Icons.logout,
//                   color: Colors.red,
//                 ),
//                 onPressed: () async {
//                   final authProvider =
//                       Provider.of<AuthProvider>(context, listen: false);
//                   await authProvider.logout(context);
//                   Navigator.pushReplacementNamed(context, '/login');
//                 },
//               ),
//               GestureDetector(
//                   onTap: _exportToExcel,
//                   onLongPress: () async {
//                     final directory = await _askUserForDirectory();
//                     if (directory != null) {
//                       setState(() {
//                         _savedDirectoryPath = directory;
//                       });
//                       final prefs = await SharedPreferences.getInstance();
//                       await prefs.setString('export_path', directory);
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                           content: Text(
//                               'The save path has been updated to $directory')));
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                           content: Text(
//                               'No path found. Please confirm that it exists.')));
//                     }
//                   },
//                   child: Padding(
//                       padding: const EdgeInsets.only(right: 18.0),
//                       child: const Icon(Icons.save,
//                           color: Colors.lightGreen, weight: 90)))
//             ]),
//         body: Column(children: [
//           Expanded(
//               flex: 2,
//               child: Container(
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 40,
//                             offset: Offset(0, 15))
//                       ]),
//                   margin: EdgeInsets.all(10),
//                   child: Stack(children: [
//                     MobileScanner(
//                         onDetect: _onDetect,
//                         scanWindow: Rect.fromLTWH(50, 100, 300, 200)),
//                     CustomPaint(
//                         painter: ScannerBorderPainter(), child: Container()),
//                     if (_showBorder)
//                       Positioned.fill(
//                           child: Container(color: Colors.lightGreen))
//                   ]))),
//           Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Row(children: [
//                 Expanded(
//                     child: TextField(
//                         controller: _manualCodeController,
//                         focusNode: _manualCodeFocusNode,
//                         decoration: InputDecoration(
//                             labelText: 'Enter the code manually',
//                             border: OutlineInputBorder()),
//                         onSubmitted: (value) => _addManualCode())),
//                 ElevatedButton(
//                     onPressed: _addManualCode,
//                     child: Icon(Icons.send, color: Colors.indigo, size: 25))
//               ])),
//           Expanded(
//               flex: 3,
//               child: SingleChildScrollView(
//                   child: Container(
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                                 color: Colors.black26,
//                                 blurRadius: 10,
//                                 offset: Offset(0, 5))
//                           ]),
//                       margin: EdgeInsets.all(10),
//                       child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Consumer<BarcodeProvider>(
//                               builder: (context, provider, child) {
//                             return DataTable(
//                                 columns: const [
//                                   DataColumn(
//                                       label: Icon(
//                                           Icons.qr_code_scanner_outlined,
//                                           color: Colors.indigo)),
//                                   DataColumn(
//                                       label: Icon(
//                                           Icons.auto_awesome_motion_outlined,
//                                           color: Colors.indigo)),
//                                   DataColumn(
//                                       label:
//                                           Icon(Icons.delete, color: Colors.red))
//                                 ],
//                                 rows: provider.scannedData.entries.map((entry) {
//                                   return DataRow(cells: [
//                                     DataCell(Text(entry.key)),
//                                     DataCell(
//                                         Text(entry.value.count.toString())),
//                                     DataCell(GestureDetector(
//                                         onTap: () =>
//                                             provider.removeBarcode(entry.key),
//                                         onLongPress: () => provider
//                                             .removeAllBarcodes(entry.key),
//                                         child: const Icon(Icons.remove_circle,
//                                             color: Colors.red)))
//                                   ]);
//                                 }).toList());
//                           })))))
//         ]));
//   }
// }
//
// class ScannerBorderPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.green
//       ..strokeWidth = 4
//       ..style = PaintingStyle.stroke;
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     canvas.drawRect(rect, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
