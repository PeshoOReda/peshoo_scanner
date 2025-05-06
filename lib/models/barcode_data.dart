import 'package:cloud_firestore/cloud_firestore.dart';

class BarcodeScanData {
  final String userId;
  final String code;
  final DateTime date;
  int count;

  BarcodeScanData(
      {required this.userId,
      required this.code,
      required this.date,
      this.count = 1});

  // تحويل BarcodeScanData إلى Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'code': code,
      'date': Timestamp.fromDate(date),
      'count': count
    };
  }

  // تحويل BarcodeScanData إلى JSON
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'code': code,
        'date': Timestamp.fromDate(date),
        'count': count
      };

  factory BarcodeScanData.fromJson(Map<String, dynamic> json) {
    return BarcodeScanData(
        userId: json['userId'] ?? '',
        code: json['code'],
        date: (json['date'] as Timestamp).toDate(),
        count: json['count'] ?? 1);
  }

  factory BarcodeScanData.fromFirestore(DocumentSnapshot doc) {
    return BarcodeScanData(
        userId: doc['userId'],
        code: doc['code'],
        date: doc['date'].toDate(),
        count: doc['count'] ?? 1);
  }
}
