
import 'package:cached_network_image/cached_network_image.dart';
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
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userImage = FirebaseAuth.instance.currentUser!.photoURL;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
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
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16.r),
        color: theme.cardTheme.color,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10),
          leading:
          _UserAvatar(profileImageUrl: chat.nurseryImageUrl),


          title: Text(
            chat.nurseryName,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: isDark ? Colors.white : Colors.black
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
                    fontStyle: lastMessage.deleted
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14.sp,
                  ),
                );
              }
              return Text(
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
                    style: TextStyle(
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
                builder: (context) =>
                    ChatScreen(
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
    class _UserAvatar extends StatelessWidget {

      final String? profileImageUrl;

      const _UserAvatar({required this.profileImageUrl});

      @override
      Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDark = themeProvider.isDarkMode;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Ensures the border is circular
            border: Border.all(
              color: Colors.transparent // Border color
               // Border width
            ),
          ),
          child: CircleAvatar(
            radius: 30.r,
              backgroundColor: isDark ? Colors.grey[600]:Colors.grey.shade300 ,

            child: ClipOval(
              child: SizedBox(
                width: 50.w, // 2 * radius (should match diameter)
                height: 50.h,
                child: CachedNetworkImage(
                  imageUrl: profileImageUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Icon(
                        Icons.person,
                        color: Theme
                            .of(context)
                            .iconTheme
                            .color
                            ?.withOpacity(0.5),
                      ),
                  errorWidget: (context, url, error) =>
                      Icon(
                        Icons.image,
                        color: Theme
                            .of(context)
                            .iconTheme
                            .color
                            ?.withOpacity(0.5),
                      ),
                ),
              ),
            ),
          ),
        );
      }
    }



