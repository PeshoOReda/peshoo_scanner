// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
//
// Future<Map<String, dynamic>> getDeviceData() async {
//   final deviceInfoPlugin = DeviceInfoPlugin();
//   final deviceData = <String, dynamic>{};
//   String deviceId = '';
//   if (Platform.isAndroid) {
//     final androidInfo = await deviceInfoPlugin.androidInfo;
//     deviceId = androidInfo.id;
//     deviceData.addAll({
//       'brand': androidInfo.brand,
//       'model': androidInfo.model,
//       'androidVersion': androidInfo.version.release,
//       'deviceId': deviceId,
//     });
//   } else if (Platform.isIOS) {
//     final iosInfo = await deviceInfoPlugin.iosInfo;
//     deviceId = iosInfo.identifierForVendor ?? '';
//     deviceData.addAll({
//       'name': iosInfo.name,
//       'systemName': iosInfo.systemName,
//       'systemVersion': iosInfo.systemVersion,
//       'model': iosInfo.model,
//       'deviceId': deviceId,
//     });
//   }
//   return deviceData;
// }
//
// Future<void> saveDeviceData(Map<String, dynamic> deviceData) async {
//   final firestore = FirebaseFirestore.instance;
//   try {
//     await firestore.collection('devices').add(deviceData);
//     if (kDebugMode) {
//       print('Data sent successfully');
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print('Error sending data: $e');
//     }
//   }
// }
//
// Future<void> checkAppLock(String deviceId) async {
//   final remoteConfig = FirebaseRemoteConfig.instance;
//   await remoteConfig.setDefaults(<String, dynamic>{
//     'app_locked': false,
//   });
//   await remoteConfig.fetchAndActivate();
//   final appLocked = remoteConfig.getBool('app_locked');
//   if (appLocked) {
//     SystemNavigator.pop();
//   }
// }
//
// Future<void> saveDeviceId(String deviceId) async {
//   final firestore = FirebaseFirestore.instance;
//   await firestore.collection('devices').doc(deviceId).set({
//     'deviceId': deviceId,
//     'timestamp': FieldValue.serverTimestamp(),
//     'peshoo': Duration(days: 3),
//   });
// }
//
// Future<void> setDeviceLockStatus(String deviceId, bool isLocked) async {
//   final firestore = FirebaseFirestore.instance;
//   await firestore.collection('devices').doc(deviceId).set({
//     'deviceId': deviceId,
//     'isLocked': isLocked,
//   });
// }
//
// Future<void> checkDeviceLockStatus(String deviceId) async {
//   final firestore = FirebaseFirestore.instance;
//   final doc = await firestore.collection('devices').doc(deviceId).get();
//   if (doc.exists) {
//     final data = doc.data();
//     final isLocked = data?['isLocked'] ?? false;
//     if (isLocked) {
//       SystemNavigator.pop();
//     }
//   }
// }
//
// Future<String> getDeviceId() async {
//   final deviceInfoPlugin = DeviceInfoPlugin();
//   String deviceId = '';
//   if (Platform.isAndroid) {
//     final androidInfo = await deviceInfoPlugin.androidInfo;
//     deviceId = androidInfo.id;
//   } else if (Platform.isIOS) {
//     final iosInfo = await deviceInfoPlugin.iosInfo;
//     deviceId = iosInfo.identifierForVendor ?? '';
//   }
//   return deviceId;
// }
