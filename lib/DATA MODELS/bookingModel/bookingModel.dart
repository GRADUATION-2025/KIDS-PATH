// Updated Booking Model
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String parentId;
  final String nurseryId;
  final String parentName;
  final String parentEmail;
  final String? parentProfileImage;
  final String nurseryName;
  final String? nurseryProfileImage;
  final DateTime dateTime;
  final String status;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final String childId;
  final String childName;
  final int childAge;
  final String childGender;
  final bool rated;

  Booking({
    required this.id,
    required this.parentId,
    required this.nurseryId,
    required this.parentName,
    required this.parentEmail,
    this.parentProfileImage,
    required this.nurseryName,
    this.nurseryProfileImage,
    required this.dateTime,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.childId,
    required this.childName,
    required this.childAge,
    required this.childGender,
    required this.rated,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      parentId: data['parentId'] ?? '',
      nurseryId: data['nurseryId'] ?? '',
      parentName: data['parentName'] ?? 'Parent',
      parentEmail: data['parentEmail'] ?? '',
      parentProfileImage: data['parentProfileImage'],
      nurseryName: data['nurseryName'] ?? '',
      nurseryProfileImage: data['nurseryProfileImage'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
      childId: data['childId'] ?? '',
      childName: data['childName'] ?? '',
      childAge: data['childAge'] ?? 0,
      childGender: data['childGender'] ?? '',
      rated: data['rated'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'nurseryId': nurseryId,
      'parentName': parentName,
      'parentEmail': parentEmail,
      'parentProfileImage': parentProfileImage,
      'nurseryName': nurseryName,
      'nurseryProfileImage': nurseryProfileImage,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'childId': childId,
      'childName': childName,
      'childAge': childAge,
      'childGender': childGender,
      'rated': rated,
      if (updatedAt != null) 'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}