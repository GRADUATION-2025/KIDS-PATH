import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool deleted;
  final String senderType; // 'nursery' or 'parent'
  final String? deletedBy; // ID of user who deleted
  final DateTime? deletedAt; // When deleted
  final String? mediaUrl;
  final String? mediaType; // 'image' or 'video'
  final String? thumbnailUrl; // for video previews

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.deleted = false,
    required this.senderType,
    this.deletedBy,
    this.deletedAt,
    this.mediaUrl,
    this.mediaType,
    this.thumbnailUrl,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImageUrl: map['senderImageUrl'],
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      deleted: map['deleted'] ?? false,
      senderType: map['senderType'] ?? 'parent',
      deletedBy: map['deletedBy'],
      deletedAt: map['deletedAt'] != null ? (map['deletedAt'] as Timestamp).toDate() : null,
      mediaUrl: map['mediaUrl'],
      mediaType: map['mediaType'],
      thumbnailUrl: map['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'deleted': deleted,
      'senderType': senderType,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  // Helper to check if message can be deleted by current user
  bool canDelete(String currentUserId, bool isCurrentUserNursery) {
    if (deleted) return false;
    return isCurrentUserNursery || senderId == currentUserId;
  }
}