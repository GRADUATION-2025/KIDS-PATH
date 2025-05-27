import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidspath/LOGIC/chat/state.dart';
import '../../DATA MODELS/chatModel/chatRoom.dart';
import '../../DATA MODELS/chatModel/massage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../SERVICES/one_signal_service.dart';
import 'package:flutter/foundation.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final OneSignalService _oneSignalService = OneSignalService();
  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  StreamSubscription<QuerySnapshot>? _messageSubscription;

  ChatCubit() : super(ChatInitial()) {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      emit(ChatError('User not authenticated'));
      return;
    }

    _notificationSubscription?.cancel();
    _messageSubscription?.cancel();

    // Listen for new messages across all chat rooms
    _messageSubscription = _firestore
        .collectionGroup('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .snapshots()
        .listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final messageData = change.doc.data() as Map<String, dynamic>;
          if (messageData['timestamp'] != null) {
            // Get the chat room details
            final chatRoomPath = change.doc.reference.path.split('/messages/')[0];
            final chatRoomDoc = await _firestore.doc(chatRoomPath).get();
            final chatRoomData = chatRoomDoc.data();

            if (chatRoomData != null &&
                (chatRoomData['participantIds'] as List).contains(userId)) {

              // Create notification document that will trigger the Cloud Function
              await _firestore.collection('notifications').add({
                'userId': userId,
                'type': 'chat',
                'title': '${messageData['senderName']} sent you a message',
                'message': messageData['mediaUrl'] != null
                    ? 'Sent you a ${messageData['mediaType'] ?? "media"}'
                    : messageData['content'],
                'timestamp': FieldValue.serverTimestamp(),
                'isRead': false,
                'chatRoomId': chatRoomDoc.id,
                'senderId': messageData['senderId'],
                'senderName': messageData['senderName'],
                'senderImageUrl': messageData['profileImageUrl'],
              });

              // Send immediate push notification for real-time feedback
              await _oneSignalService.sendNotificationToUser(
                userId: userId,
                title: '${messageData['name']} sent you a message',
                message: messageData['mediaUrl'] != null
                    ? 'Sent you a ${messageData['mediaType'] ?? "media"}'
                    : messageData['content'],
                data: {
                  'type': 'chat',
                  'chatRoomId': chatRoomDoc.id,
                  'senderId': messageData['senderId'],
                  'senderName': messageData['name'],
                  'senderImageUrl': messageData['profileImageUrl'],
                  'shouldNavigate': true,
                },
              );
            }
          }
        }
      }
    }, onError: (error) {
      emit(ChatError('Failed to monitor messages: $error'));
    });
  }

  Future<void> joinNurseryChat(String nurseryId, String parentId) async {
    try {
      emit(ChatLoading());
      final nurseryDoc = await _firestore.collection('nurseries').doc(nurseryId).get();
      if (!nurseryDoc.exists) {
        emit(ChatError('Nursery not found'));
        return;
      }

      final parentData = await _getUserData(parentId, false);
      final nurseryData = await _getUserData(nurseryId, true);

      await _ensureChatRoomExists(
        nurseryId: nurseryId,
        parentId: parentId,
        nurseryData: nurseryData,
        parentData: parentData,
      );

      emit(ChatJoinedSuccessfully());
    } catch (e) {
      emit(ChatError('Failed to join chat: ${e.toString()}'));
    }
  }

  Future<void> _ensureChatRoomExists({
    required String nurseryId,
    required String parentId,
    required Map<String, dynamic> nurseryData,
    required Map<String, dynamic> parentData,
  }) async {
    final chatId = nurseryId;
    final chatRef = _firestore.collection('chatRooms').doc(chatId);

    await _firestore.runTransaction((transaction) async {
      final chatDoc = await transaction.get(chatRef);

      if (!chatDoc.exists) {
        transaction.set(chatRef, {
          'id': chatId,
          'nurseryId': nurseryId,
          'nurseryName': nurseryData['name'],
          'nurseryImageUrl': nurseryData['profileImageUrl'],
          'participantIds': [nurseryId, parentId],
          'participantData': {
            parentId: {
              'name': parentData['name'],
              'profileImageUrl': parentData['profileImageUrl'],
              'type': 'parent'
            },
            nurseryId: {
              'name': nurseryData['name'],
              'profileImageUrl': nurseryData['profileImageUrl'],
              'type': 'nursery'
            }
          },
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        final existingParticipants = List<String>.from(chatDoc['participantIds'] ?? []);
        if (!existingParticipants.contains(parentId)) {
          transaction.update(chatRef, {
            'participantIds': FieldValue.arrayUnion([parentId]),
            'participantData.$parentId': {
              'name': parentData['name'],
              'profileImageUrl': parentData['profileImageUrl'],
              'type': 'parent'
            },
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  Future<Map<String, dynamic>> _getUserData(String userId, bool isNursery) async {
    final collection = isNursery ? 'nurseries' : 'parents';
    final doc = await _firestore.collection(collection).doc(userId).get();

    if (!doc.exists) {
      return {
        'name': isNursery ? 'Nursery' : 'Parent',
        'profileImageUrl': "profileImageUrl"
      };
    }

    final data = doc.data()!;
    return {
      'name': data['name'] ?? (isNursery ? 'Nursery' : 'Parent'),
      'profileImageUrl': data['profileImageUrl']
    };
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String content,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    String? mediaUrl,
    String? mediaType, String? thumbnailUrl,
  }) async {
    try {

      final isNursery = await isUserNursery(senderId);
      final userData = await _getUserData(senderId, isNursery);

      final timestamp = FieldValue.serverTimestamp();
      final messageRef = _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc();

      final message = {
        'id': messageRef.id,
        'content': content,
        'senderId': senderId,
        'senderName': userData["name"],
        'senderImageUrl': userData['profileImageUrl'],
        'timestamp': timestamp,
        'isRead': isNursery,
        'deleted': false,
        'senderType': await isUserNursery(senderId) ? 'nursery' : 'parent',
      };

      if (mediaUrl != null) {
        message['mediaUrl'] = mediaUrl;
        message['mediaType'] = mediaType;
      }

      await messageRef.set(message);

      // Update chat room's last message and timestamp
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': content,
        'lastMessageTimestamp': timestamp,
        'lastUpdated': timestamp,
      });

      // Get recipient's ID and send notification
      final chatRoom = await _firestore.collection('chatRooms').doc(chatRoomId).get();
      if (chatRoom.exists) {
        final chatData = chatRoom.data()!;
        final participantIds = List<String>.from(chatData['participantIds'] ?? []);
        final recipientId = participantIds.firstWhere((id) => id != senderId);

        // Create notification document that will trigger the Cloud Function
        await _firestore.collection('notifications').add({
          'userId': recipientId,
          'type': 'chat',
          'title': '$senderName sent you a message',
          'message': mediaUrl != null ? 'Sent you a ${mediaType ?? "media"}' : content,
          'timestamp': timestamp,
          'isRead': false,
          'chatRoomId': chatRoomId,
          'senderId': senderId,
          'senderName': userData["name"],
          'senderImageUrl': userData['profileImageUrl'],
        });

        // Send immediate push notification
        await _oneSignalService.sendNotificationToUser(
          userId: recipientId,
          title: '$senderName sent you a message',
          message: mediaUrl != null ? 'Sent you a ${mediaType ?? "media"}' : content,
          data: {
            'type': 'chat',
            'chatRoomId': chatRoomId,
            'senderId': senderId,
            'senderName': userData["name"],
            'senderImageUrl': userData['profileImageUrl'],
          },
        );
      }
    } catch (e) {
      debugPrint('Error in sendMessage: $e');
      emit(ChatError('Failed to send message: $e'));
    }
  }

  Stream<List<Message>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }


  Stream<List<ChatRoom>> getUserChats(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }




  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      final messages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (messages.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      emit(ChatError('Failed to update read status: $e'));
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    _messageSubscription?.cancel();
    return super.close();
  }

  Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
    required String currentUserId,
    required bool isCurrentUserNursery
  }) async {
    try {
      final messageRef = _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId);

      final messageDoc = await messageRef.get();
      if (!messageDoc.exists) {
        emit(ChatError('Message not found'));
        return;
      }

      final messageData = messageDoc.data()!;
      final senderId = messageData['senderId'] as String;

      // Check if user has permission to delete
      if (!isCurrentUserNursery && senderId != currentUserId) {
        emit(ChatError('You do not have permission to delete this message'));
        return;
      }

      await messageRef.update({
        'deleted': true,
        'deletedBy': currentUserId,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(ChatError('Failed to delete message: $e'));
    }
  }

  Future<bool> isUserNursery(String userId) async {
    try {
      final nurseryDoc = await _firestore.collection('nurseries').doc(userId).get();
      return nurseryDoc.exists;
    } catch (e) {
      emit(ChatError('Failed to check user type: $e'));
      return false;
    }
  }
}

extension on OneSignalService {
  sendNotificationToUser({required String userId, required String title, required message, required Map<String, dynamic> data}) {}
}