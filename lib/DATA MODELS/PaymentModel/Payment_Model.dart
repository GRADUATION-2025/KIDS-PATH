import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentInfo {
  final String parentId;
  final String last4Digits;
  final String cardBrand;
  final String expiration;
  final Timestamp timestamp;

  PaymentInfo({
    required this.parentId,
    required this.last4Digits,
    required this.cardBrand,
    required this.expiration,
    required this.timestamp,
  });

  factory PaymentInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentInfo(
      parentId: data['parentId'],
      last4Digits: data['last4Digits'],
      cardBrand: data['cardBrand'],
      expiration: data['expiration'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'last4Digits': last4Digits,
      'cardBrand': cardBrand,
      'expiration': expiration,
      'timestamp': timestamp,
    };
  }
}