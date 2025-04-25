//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kidspath/LOGIC/chat/state.dart';
//
// import '../../DATA MODELS/chatModel/chatRoom.dart';
// import '../../DATA MODELS/chatModel/massage.dart';
//
// class ChatCubit extends Cubit<ChatState> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   ChatCubit() : super(ChatInitial());
//
//   Future<void> initializeUserChats(String userId) async {
//     try {
//       emit(ChatLoading());
//
//       // Prevent nurseries from initializing chats
//       if (await isUserNursery(userId)) {
//         emit(ChatError('please wait '));
//         return;
//       }
//
//       final nurseries = await _firestore.collection('nurseries').get();
//       for (final nursery in nurseries.docs) {
//         await _ensureParentInNurseryChat(nursery, userId);
//       }
//
//       emit(ChatsInitialized());
//     } catch (e) {
//       emit(ChatError('Failed to initialize chats: ${e.toString()}'));
//     }
//   }
//
//   Future<void> _ensureParentInNurseryChat(
//       QueryDocumentSnapshot nursery,
//       String parentId) async {
//     try {
//       final nurseryId = nursery.id;
//       final chatId = nurseryId; // Chat ID = Nursery ID
//
//       final parentDoc = await _firestore.collection('parents').doc(parentId).get();
//       if (!parentDoc.exists) {
//         emit(ChatError('Parent not found'));
//         return;
//       }
//
//       final parentData = parentDoc.data() as Map<String, dynamic>;
//       final nurseryData = nursery.data() as Map<String, dynamic>;
//
//       final chatRef = _firestore.collection('chatRooms').doc(chatId);
//
//       await _firestore.runTransaction((transaction) async {
//         final chatDoc = await transaction.get(chatRef);
//
//         if (!chatDoc.exists) {
//           transaction.set(chatRef, {
//             'id': chatId,
//             'nurseryId': nurseryId,
//             'nurseryName': nurseryData['name'] ?? 'Nursery',
//             'nurseryImageUrl': nurseryData['profileImageUrl'],
//             'participantIds': [nurseryId, parentId],
//             'participantData': {
//               parentId: {
//                 'name': parentData['name'] ?? 'Parent',
//                 'imageUrl': parentData['profileImageUrl'],
//                 'type': 'parent'
//               },
//               nurseryId: {
//                 'name': nurseryData['name'] ?? 'Nursery',
//                 'imageUrl': nurseryData['profileImageUrl'],
//                 'type': 'nursery'
//               }
//             },
//             'createdAt': FieldValue.serverTimestamp(),
//             'lastUpdated': FieldValue.serverTimestamp(),
//           });
//         } else {
//           final existingParticipants =
//           List<String>.from(chatDoc['participantIds'] ?? []);
//
//           if (!existingParticipants.contains(parentId)) {
//             transaction.update(chatRef, {
//               'participantIds': FieldValue.arrayUnion([parentId]),
//               'participantData.$parentId': {
//                 'name': parentData['name'] ?? 'Parent',
//                 'imageUrl': parentData['profileImageUrl'],
//                 'type': 'parent'
//               },
//               'lastUpdated': FieldValue.serverTimestamp(),
//             });
//           }
//         }
//       });
//     } catch (e) {
//       emit(ChatError('Failed to add parent to nursery chat: ${e.toString()}'));
//     }
//   }
//
//   Stream<List<ChatRoom>> getUserChats(String userId) {
//     return _firestore
//         .collection('chatRooms')
//         .where('participantIds', arrayContains: userId)
//         .orderBy('lastUpdated', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => ChatRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id))
//         .toList());
//   }
//
//   Future<void> sendMessage({
//     required String chatRoomId,
//     required String senderId,
//     required String content, required String senderName, String? senderImageUrl,
//   }) async {
//     try {
//       final nurseryDoc = await _firestore.collection('nurseries').doc(senderId).get();
//       final isNursery = nurseryDoc.exists;
//
//       String senderName;
//       String? senderImageUrl;
//
//       if (isNursery) {
//         final nurseryData = nurseryDoc.data() as Map<String, dynamic>?;
//         senderName = nurseryData?['name'] ?? 'Nursery';
//         senderImageUrl = nurseryData?['profileImageUrl'];
//       } else {
//         final parentDoc = await _firestore.collection('parents').doc(senderId).get();
//         final parentData = parentDoc.data() as Map<String, dynamic>?;
//         senderName = parentData?['name'] ?? 'Parent';
//         senderImageUrl = parentData?['profileImageUrl'];
//       }
//
//       final messageRef = _firestore
//           .collection('chatRooms')
//           .doc(chatRoomId)
//           .collection('messages')
//           .doc();
//
//       final batch = _firestore.batch();
//
//       batch.set(messageRef, {
//         'id': messageRef.id,
//         'senderId': senderId,
//         'senderName': senderName,
//         'senderImageUrl': senderImageUrl,
//         'content': content,
//         'timestamp': FieldValue.serverTimestamp(),
//         'isRead': isNursery,
//         'senderType': isNursery ? 'nursery' : 'parent',
//         'deleted': false,
//       });
//
//       batch.update(
//         _firestore.collection('chatRooms').doc(chatRoomId),
//         {'lastUpdated': FieldValue.serverTimestamp()},
//       );
//
//       await batch.commit();
//     } catch (e) {
//       emit(ChatError('Failed to send message: $e'));
//     }
//   }
//
//   Stream<List<Message>> getMessages(String chatRoomId) {
//     return _firestore
//         .collection('chatRooms')
//         .doc(chatRoomId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
//         .toList());
//   }
//
//   Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
//     try {
//       final messages = await _firestore
//           .collection('chatRooms')
//           .doc(chatRoomId)
//           .collection('messages')
//           .where('senderId', isNotEqualTo: userId)
//           .where('isRead', isEqualTo: false)
//           .get();
//
//       if (messages.docs.isEmpty) return;
//
//       final batch = _firestore.batch();
//       for (final doc in messages.docs) {
//         batch.update(doc.reference, {'isRead': true});
//       }
//       await batch.commit();
//     } catch (e) {
//       emit(ChatError('Failed to update read status: $e'));
//     }
//   }
//
//   Future<Map<String, dynamic>> getParticipantInfo(String participantId) async {
//     final nurseryDoc = await _firestore.collection('nurseries').doc(participantId).get();
//     if (nurseryDoc.exists) {
//       final data = nurseryDoc.data() as Map<String, dynamic>?;
//       return {
//         'name': data?['name'] ?? 'Nursery',
//         'imageUrl': data?['profileImageUrl'],
//         'type': 'nursery'
//       };
//     }
//
//     final parentDoc = await _firestore.collection('parents').doc(participantId).get();
//     final parentData = parentDoc.data() as Map<String, dynamic>?;
//     return {
//       'name': parentData?['name'] ?? 'Parent',
//       'imageUrl': parentData?['profileImageUrl'],
//       'type': 'parent'
//     };
//   }
//
//   Future<bool> isUserNursery(String userId) async {
//     final doc = await _firestore.collection('nurseries').doc(userId).get();
//     return doc.exists;
//   }
//
//   Future<void> deleteMessage({
//     required String chatRoomId,
//     required String messageId,
//     required String currentUserId,
//     required bool isCurrentUserNursery,
//   }) async {
//     try {
//       final messageDoc = await _firestore
//           .collection('chatRooms')
//           .doc(chatRoomId)
//           .collection('messages')
//           .doc(messageId)
//           .get();
//
//       if (!messageDoc.exists) {
//         emit(ChatError('Message not found'));
//         return;
//       }
//
//       final message = Message.fromMap(messageDoc.data() as Map<String, dynamic>);
//
//       if (!(isCurrentUserNursery || message.senderId == currentUserId)) {
//         emit(ChatError('You cannot delete this message'));
//         return;
//       }
//
//       await _firestore
//           .collection('chatRooms')
//           .doc(chatRoomId)
//           .collection('messages')
//           .doc(messageId)
//           .update({
//         'deleted': true,
//         'deletedBy': currentUserId,
//         'deletedAt': FieldValue.serverTimestamp(),
//       });
//
//       await _firestore.collection('chatRooms').doc(chatRoomId).update({
//         'lastUpdated': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       emit(ChatError('Failed to delete message: ${e.toString()}'));
//     }
//   }
// }
//
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidspath/LOGIC/chat/state.dart';
import '../../DATA MODELS/chatModel/chatRoom.dart';
import '../../DATA MODELS/chatModel/massage.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatCubit() : super(ChatInitial());

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
          'nurseryImageUrl': nurseryData['imageUrl'],
          'participantIds': [nurseryId, parentId],
          'participantData': {
            parentId: {
              'name': parentData['name'],
              'imageUrl': parentData['imageUrl'],
              'type': 'parent'
            },
            nurseryId: {
              'name': nurseryData['name'],
              'imageUrl': nurseryData['imageUrl'],
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
              'imageUrl': parentData['imageUrl'],
              'type': 'parent'
            },
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      }
    });
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

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content, required String senderName, String? senderImageUrl,
  }) async {
    try {
      final isNursery = await isUserNursery(senderId);
      final userData = await _getUserData(senderId, isNursery);

      final messageRef = _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc();

      final batch = _firestore.batch();

      batch.set(messageRef, {
        'id': messageRef.id,
        'senderId': senderId,
        'senderName': userData['name'],
        'senderImageUrl': userData['imageUrl'],
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': isNursery,
        'senderType': isNursery ? 'nursery' : 'parent',
        'deleted': false,
      });

      batch.update(
        _firestore.collection('chatRooms').doc(chatRoomId),
        {'lastUpdated': FieldValue.serverTimestamp()},
      );

      await batch.commit();
    } catch (e) {
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

  Future<Map<String, dynamic>> _getUserData(String userId, bool isNursery) async {
    final collection = isNursery ? 'nurseries' : 'parents';
    final doc = await _firestore.collection(collection).doc(userId).get();

    if (!doc.exists) {
      return {
        'name': isNursery ? 'Nursery' : 'Parent',
        'imageUrl': null
      };
    }

    final data = doc.data()!;
    return {
      'name': data['name'] ?? (isNursery ? 'Nursery' : 'Parent'),
      'imageUrl': data['profileImageUrl']
    };
  }

  Future<bool> isUserNursery(String userId) async {
    final doc = await _firestore.collection('nurseries').doc(userId).get();
    return doc.exists;
  }

  Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
    required String currentUserId,
    required bool isCurrentUserNursery,
  }) async {
    try {
      final messageDoc = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) {
        emit(ChatError('Message not found'));
        return;
      }

      final message = Message.fromMap(messageDoc.data() as Map<String, dynamic>);

      if (!(isCurrentUserNursery || message.senderId == currentUserId)) {
        emit(ChatError('You cannot delete this message'));
        return;
      }

      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'deleted': true,
        'deletedBy': currentUserId,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(ChatError('Failed to delete message: ${e.toString()}'));
    }
  }
}