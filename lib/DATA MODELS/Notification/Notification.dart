import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String bookingId;
  final Timestamp timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.bookingId,
    required this.timestamp,
    required this.isRead,
  });

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
    );
  }
}
