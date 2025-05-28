
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../DATA MODELS/chatModel/chatRoom.dart';
import '../../DATA MODELS/chatModel/massage.dart';
import '../../LOGIC/chat/cubit.dart';
import '../../THEME/theme_provider.dart';
import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import 'chat.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userImage = FirebaseAuth.instance.currentUser!.photoURL;

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize:  Size.fromHeight(100.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return AppGradients.Projectgradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  );
                },
                child:  Text(
                  'Chats',
                  style: TextStyle(
                    fontSize:40.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 2.h,
                width: MediaQuery.of(context).size.width / 2,
                decoration: const BoxDecoration(
                  gradient: AppGradients.Projectgradient,
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: context.read<ChatCubit>().getUserChats(userId),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(child: CircularProgressIndicator());
          // }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'No active chats yet',
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 8.h),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16.r),
        color: isDark?Colors.grey[300]:Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 28.r,
            backgroundImage: chat.nurseryImageUrl != null
                ? NetworkImage(chat.nurseryImageUrl!)
                : null,
            child: chat.nurseryImageUrl == null
                ? Text(chat.nurseryName.substring(0, 1).toUpperCase())
                : null,
          ),
          title: Text(
            chat.nurseryName,
            style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isDark?Colors.black:Colors.black
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
                    fontSize: 14.sp,
                  ),
                );
              }
              return  Text(
                'No messages yet',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
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
                  radius: 12.r,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    unreadCount.toString(),
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
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