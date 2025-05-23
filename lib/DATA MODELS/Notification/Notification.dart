// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class NotificationModel {
//   final String id;
//   final String type;
//   final String title;
//   final String message;
//   final String bookingId;
//   final Timestamp timestamp;
//   final bool isRead;
//
//   NotificationModel({
//     required this.id,
//     required this.type,
//     required this.title,
//     required this.message,
//     required this.bookingId,
//     required this.timestamp,
//     required this.isRead,
//   });
//
//   factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return NotificationModel(
//       id: doc.id,
//       type: data['type'] as String,
//       title: data['title'] as String,
//       message: data['message'] as String,
//       bookingId: data['bookingId'] as String? ?? '',
//       timestamp: data['timestamp'] as Timestamp,
//       isRead: data['isRead'] as bool? ?? false,
//     );
//   }
// }
//
//

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String bookingId;
  final Timestamp timestamp;
  final bool isRead;
  final String? childName; // ✅ New field

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.bookingId,
    required this.timestamp,
    required this.isRead,
    this.childName, // ✅ Include in constructor
  });

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? bookingId,
    Timestamp? timestamp,
    bool? isRead,
    String? childName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      bookingId: bookingId ?? this.bookingId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      childName: childName ?? this.childName,
    );
  }
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      type: data['type'] as String,
      title: data['title'] as String,
      message: data['message'] as String,
      bookingId: data['bookingId'] as String? ?? '',
      timestamp: data['timestamp'] as Timestamp,
      isRead: data['isRead'] as bool? ?? false,
      childName: data['childName'] as String?, // ✅ Safely parse from Firestore
    );
  }
}