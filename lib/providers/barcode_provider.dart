import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peshoo_scanner/models/barcode_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';

class BarcodeProvider with ChangeNotifier {
  Map<String, BarcodeScanData> _scannedData = {};
  Map<String, BarcodeScanData> get scannedData => _scannedData;

  BarcodeProvider(BuildContext context) {
    _loadScannedData(context);
  }

  void _loadScannedData(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final String? data =
        prefs.getString('scannedData_${authProvider.user!.uid}');
    if (data != null) {
      final Map<String, dynamic> jsonData = json.decode(data);
      _scannedData = jsonData
          .map((key, value) => MapEntry(key, BarcodeScanData.fromJson(value)));
      notifyListeners();
    }
  }

  Future<void> _saveScannedData(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scanDataProvider =
        Provider.of<ScanDataProvider>(context, listen: false);

    final List<BarcodeScanData> barcodeList = _scannedData.values.map((data) {
      return BarcodeScanData(
          userId: authProvider.user!.uid,
          code: data.code,
          date: DateTime.now(),
          count: data.count);
    }).toList();

    for (final data in barcodeList) {
      await scanDataProvider.saveScanData(data);
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('scannedData_${authProvider.user!.uid}',
        json.encode(_scannedData)); // تخزين البيانات مع UID
  }

  void addBarcode(BuildContext context, String code) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_scannedData.containsKey(code)) {
      _scannedData[code]!.count += 1;
    } else {
      _scannedData[code] = BarcodeScanData(
          userId: authProvider.user!.uid,
          code: code,
          date: DateTime.now(),
          count: 1);
    }

    _saveScannedData(context);
    notifyListeners();
  }

  void removeBarcode(BuildContext context, String code) {
    if (_scannedData.containsKey(code)) {
      _scannedData[code]!.count -= 1;
      if (_scannedData[code]!.count <= 0) {
        _scannedData.remove(code);
      }
      _saveScannedData(context);
      notifyListeners();
    }
  }

  void removeAllBarcodes(BuildContext context, String code) {
    if (_scannedData.containsKey(code)) {
      _scannedData.remove(code);
      _saveScannedData(context);
      notifyListeners();
    }
  }
}

class ScanDataProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BarcodeScanData>> getUserScanData(String userId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('scanData')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => BarcodeScanData.fromFirestore(doc))
        .toList();
  }

  Future<void> saveScanData(BarcodeScanData data) async {
    await _firestore
        .collection('scanData')
        .doc(data.code)
        .set(data.toFirestore(), SetOptions(merge: true));
  }
}
