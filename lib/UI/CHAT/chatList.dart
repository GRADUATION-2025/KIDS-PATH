//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../DATA MODELS/chatModel/chatRoom.dart';
// import '../../DATA MODELS/chatModel/massage.dart';
// import '../../LOGIC/chat/cubit.dart';
// import '../../LOGIC/chat/state.dart';
// import 'chat.dart';
//
// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({super.key});
//
//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }
//
// class _ChatListScreenState extends State<ChatListScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeChats();
//   }
//
//   void _initializeChats() {
//     final userId = FirebaseAuth.instance.currentUser!.uid;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ChatCubit>().initializeUserChats(userId); // Changed to initializeUserChats
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser!.uid;
//     final userImage = FirebaseAuth.instance.currentUser!.photoURL;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Nursery Chats'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _initializeChats,
//           ),
//         ],
//       ),
//       body: BlocConsumer<ChatCubit, ChatState>(
//         listener: (context, state) {
//           if (state is ChatError) {
//
//           }
//         },
//         builder: (context, state) {
//           if (state is ChatLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           return StreamBuilder<List<ChatRoom>>(
//             stream: context.read<ChatCubit>().getUserChats(userId),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               final chats = snapshot.data!;
//
//               if (chats.isEmpty) {
//                 return const Center(
//                   child: Text('No chats available yet'),
//                 );
//               }
//
//               return ListView.builder(
//                 padding: const EdgeInsets.all(8),
//                 itemCount: chats.length,
//                 itemBuilder: (context, index) {
//                   final chat = chats[index];
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: chat.nurseryImageUrl != null
//                             ? NetworkImage(chat.nurseryImageUrl!)
//                             : null,
//                         child: chat.nurseryImageUrl == null
//                             ? Text(chat.nurseryName.substring(0, 1))
//                             : null,
//                       ),
//                       title: Text(chat.nurseryName),
//                       subtitle: StreamBuilder<QuerySnapshot>(
//                         stream: _firestore
//                             .collection('chatRooms')
//                             .doc(chat.id)
//                             .collection('messages')
//                             .orderBy('timestamp', descending: true)
//                             .limit(1)
//                             .snapshots(),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//                             final lastMessage = Message.fromMap(
//                                 snapshot.data!.docs.first.data() as Map<String, dynamic>);
//                             return Text(
//                               lastMessage.content,
//                               overflow: TextOverflow.ellipsis,
//                             );
//                           }
//                           return const Text('No messages yet');
//                         },
//                       ),
//                       onTap: () {
//                         // Mark messages as read when entering chat
//                         context.read<ChatCubit>().markMessagesAsRead(chat.id, userId);
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ChatScreen(
//                               chatRoomId: chat.id,
//                               nurseryName: chat.nurseryName,
//                               nurseryImageUrl: chat.nurseryImageUrl,
//                               userId: userId,
//                               userImage: userImage,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../DATA MODELS/chatModel/chatRoom.dart';
// import '../../DATA MODELS/chatModel/massage.dart';
// import '../../LOGIC/chat/cubit.dart';
// import 'chat.dart';
//
// class ChatListScreen extends StatelessWidget {
//   const ChatListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser!.uid;
//     final userImage = FirebaseAuth.instance.currentUser!.photoURL;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Chats'),
//       ),
//       body: StreamBuilder<List<ChatRoom>>(
//         stream: context.read<ChatCubit>().getUserChats(userId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           final chats = snapshot.data ?? [];
//
//           if (chats.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     'No active chats yet',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Start chatting by visiting a nursery profile',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final chat = chats[index];
//               return _ChatListItem(
//                 chat: chat,
//                 userId: userId,
//                 userImage: userImage,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _ChatListItem extends StatelessWidget {
//   final ChatRoom chat;
//   final String userId;
//   final String? userImage;
//
//   const _ChatListItem({
//     required this.chat,
//     required this.userId,
//     this.userImage,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: chat.nurseryImageUrl != null
//               ? NetworkImage(chat.nurseryImageUrl!)
//               : null,
//           child: chat.nurseryImageUrl == null
//               ? Text(chat.nurseryName.substring(0, 1))
//               : null,
//         ),
//         title: Text(chat.nurseryName),
//         subtitle: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('chatRooms')
//               .doc(chat.id)
//               .collection('messages')
//               .orderBy('timestamp', descending: true)
//               .limit(1)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//               final lastMessage = Message.fromMap(
//                   snapshot.data!.docs.first.data() as Map<String, dynamic>);
//               return Text(
//                 lastMessage.deleted
//                     ? 'Message deleted'
//                     : lastMessage.content,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontStyle: lastMessage.deleted
//                       ? FontStyle.italic
//                       : FontStyle.normal,
//                   color: lastMessage.deleted
//                       ? Colors.grey
//                       : null,
//                 ),
//               );
//             }
//             return const Text('No messages yet');
//           },
//         ),
//         trailing: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('chatRooms')
//               .doc(chat.id)
//               .collection('messages')
//               .where('senderId', isNotEqualTo: userId)
//               .where('isRead', isEqualTo: false)
//               .snapshots(),
//           builder: (context, snapshot) {
//             final unreadCount = snapshot.data?.size ?? 0;
//             if (unreadCount > 0) {
//               return CircleAvatar(
//                 radius: 12,
//                 backgroundColor: Colors.blue,
//                 child: Text(
//                   unreadCount.toString(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                   ),
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//         onTap: () {
//           context.read<ChatCubit>().markMessagesAsRead(chat.id, userId);
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatScreen(
//                 chatRoomId: chat.id,
//                 nurseryName: chat.nurseryName,
//                 nurseryImageUrl: chat.nurseryImageUrl,
//                 userId: userId,
//                 userImage: userImage,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../DATA MODELS/chatModel/chatRoom.dart';
// import '../../DATA MODELS/chatModel/massage.dart';
// import '../../LOGIC/chat/cubit.dart';
// import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
// import 'chat.dart';
//
// class ChatListScreen extends StatelessWidget {
//   const ChatListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser!.uid;
//     final userImage = FirebaseAuth.instance.currentUser!.photoURL;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(height: 20),
//             AppBar(
//
//               backgroundColor: Colors.white,
//               elevation: 0,
//               centerTitle: true,
//               automaticallyImplyLeading: false,
//               title: ShaderMask(
//                 shaderCallback: (Rect bounds) {
//                   return AppGradients.Projectgradient.createShader(
//                     Rect.fromLTWH(0, 0, bounds.width, bounds.height),
//                   );
//                 },
//                 child: const Text(
//                   'Chats',
//                   style: TextStyle(
//                     fontSize:50,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white, // Required for ShaderMask
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               height: 3,
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: AppGradients.Projectgradient,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: StreamBuilder<List<ChatRoom>>(
//         stream: context.read<ChatCubit>().getUserChats(userId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           final chats = snapshot.data ?? [];
//
//           if (chats.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     'No active chats yet',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Start chatting by visiting a nursery profile',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final chat = chats[index];
//               return _ChatListItem(
//                 chat: chat,
//                 userId: userId,
//                 userImage: userImage,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _ChatListItem extends StatelessWidget {
//   final ChatRoom chat;
//   final String userId;
//   final String? userImage;
//
//   const _ChatListItem({
//     required this.chat,
//     required this.userId,
//     this.userImage,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: chat.nurseryImageUrl != null
//               ? NetworkImage(chat.nurseryImageUrl!)
//               : null,
//           child: chat.nurseryImageUrl == null
//               ? Text(chat.nurseryName.substring(0, 1))
//               : null,
//         ),
//         title: Text(chat.nurseryName),
//         subtitle: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('chatRooms')
//               .doc(chat.id)
//               .collection('messages')
//               .orderBy('timestamp', descending: true)
//               .limit(1)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//               final lastMessage = Message.fromMap(
//                   snapshot.data!.docs.first.data() as Map<String, dynamic>);
//               return Text(
//                 lastMessage.deleted
//                     ? 'Message deleted'
//                     : lastMessage.content,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontStyle: lastMessage.deleted
//                       ? FontStyle.italic
//                       : FontStyle.normal,
//                   color: lastMessage.deleted
//                       ? Colors.grey
//                       : null,
//                 ),
//               );
//             }
//             return const Text('No messages yet');
//           },
//         ),
//         trailing: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('chatRooms')
//               .doc(chat.id)
//               .collection('messages')
//               .where('senderId', isNotEqualTo: userId)
//               .where('isRead', isEqualTo: false)
//               .snapshots(),
//           builder: (context, snapshot) {
//             final unreadCount = snapshot.data?.size ?? 0;
//             if (unreadCount > 0) {
//               return CircleAvatar(
//                 radius: 12,
//                 backgroundColor: Colors.blue,
//                 child: Text(
//                   unreadCount.toString(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                   ),
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//         onTap: () {
//           context.read<ChatCubit>().markMessagesAsRead(chat.id, userId);
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatScreen(
//                 chatRoomId: chat.id,
//                 nurseryName: chat.nurseryName,
//                 nurseryImageUrl: chat.nurseryImageUrl,
//                 userId: userId,
//                 userImage: userImage,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../DATA MODELS/chatModel/chatRoom.dart';
import '../../DATA MODELS/chatModel/massage.dart';
import '../../LOGIC/chat/cubit.dart';
import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import 'chat.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userImage = FirebaseAuth.instance.currentUser!.photoURL;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return AppGradients.Projectgradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  );
                },
                child: const Text(
                  'Chats',
                  style: TextStyle(
                    fontSize:40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              height: 3,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppGradients.Projectgradient,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: context.read<ChatCubit>().getUserChats(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No active chats yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start chatting by visiting a nursery profile',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatListItem(
                chat: chat,
                userId: userId,
                userImage: userImage,
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatRoom chat;
  final String userId;
  final String? userImage;

  const _ChatListItem({
    required this.chat,
    required this.userId,
    this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: chat.nurseryImageUrl != null
                ? NetworkImage(chat.nurseryImageUrl!)
                : null,
            child: chat.nurseryImageUrl == null
                ? Text(chat.nurseryName.substring(0, 1).toUpperCase())
                : null,
          ),
          title: Text(
            chat.nurseryName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chatRooms')
                .doc(chat.id)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final lastMessage = Message.fromMap(
                    snapshot.data!.docs.first.data() as Map<String, dynamic>);
                return Text(
                  lastMessage.deleted ? 'Message deleted' : lastMessage.content,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontStyle: lastMessage.deleted ? FontStyle.italic : FontStyle.normal,
                    color: lastMessage.deleted ? Colors.grey : Colors.black87,
                    fontSize: 14,
                  ),
                );
              }
              return const Text(
                'No messages yet',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              );
            },
          ),
          trailing: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chatRooms')
                .doc(chat.id)
                .collection('messages')
                .where('senderId', isNotEqualTo: userId)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.size ?? 0;
              if (unreadCount > 0) {
                return CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          onTap: () {
            context.read<ChatCubit>().markMessagesAsRead(chat.id, userId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatRoomId: chat.id,
                  nurseryName: chat.nurseryName,
                  nurseryImageUrl: chat.nurseryImageUrl,
                  userId: userId,
                  userImage: userImage,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}