
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String nurseryId;
  final String nurseryName;
  final String? nurseryImageUrl;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime lastUpdated;

  ChatRoom({
    required this.id,
    required this.nurseryId,
    required this.nurseryName,
    this.nurseryImageUrl,
    required this.participantIds,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      nurseryId: map['nurseryId'] ?? '',
      nurseryName: map['nurseryName'] ?? 'Nursery',
      nurseryImageUrl: map['nurseryImageUrl'],
      participantIds: List<String>.from(map['participantIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nurseryId': nurseryId,
      'nurseryName': nurseryName,
      'nurseryImageUrl': nurseryImageUrl,
      'participantIds': participantIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
