import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../../DATA MODELS/chatModel/chatRoom.dart';
import '../../DATA MODELS/chatModel/massage.dart';
import '../../LOGIC/chat/cubit.dart';
import '../../LOGIC/chat/state.dart';
import '../../SERVICES/one_signal_service.dart';
import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import 'chat.dart';
import '../../THEME/theme_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatCubit _chatCubit;
  final OneSignalService _oneSignalService = OneSignalService();

  @override
  void initState() {
    super.initState();
    _chatCubit = ChatCubit();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _chatCubit.close();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _oneSignalService.initialize();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _oneSignalService.setExternalUserId(userId);
        await _oneSignalService.setUserRole('chat_user');

        if (!mounted) return;

        OneSignal.Notifications.addForegroundWillDisplayListener((event) {
          if (!mounted) return;
          final data = event.notification.additionalData;
          if (data != null && data['type'] == 'chat') {
            _handleNotification(
              event.notification.title ?? '',
              event.notification.body ?? '',
              data,
            );
          }
        });

        OneSignal.Notifications.addClickListener((event) {
          if (!mounted) return;
          final data = event.notification.additionalData;
          if (data != null && data['type'] == 'chat') {
            _navigateToChat(data);
          }
        });
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  void _handleNotification(String title, String message, Map<String, dynamic> data) {
    if (!mounted) return;
    // Let OneSignal handle the notification display
  }

  void _navigateToChat(Map<String, dynamic> data) {
    if (!mounted) return;

    final chatRoomId = data['chatRoomId'] as String;
    final senderName = data['senderName'] as String;
    final senderImageUrl = data['senderImageUrl'] as String?;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final shouldNavigate = data['shouldNavigate'] as bool? ?? false;

    if (shouldNavigate) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomId,
            nurseryName: senderName,
            nurseryImageUrl: senderImageUrl,
            userId: userId,
            userImage: FirebaseAuth.instance.currentUser!.photoURL,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userImage = FirebaseAuth.instance.currentUser?.photoURL;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (userId == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        body: Center(
          child: Text(
            'Please sign in to access chats',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: _chatCubit,
      child: BlocListener<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return AppGradients.Projectgradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      );
                    },
                    child: Text(
                      'Chats',
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 3.h,
                    width: MediaQuery.of(context).size.width * 0.4,
                    margin: EdgeInsets.only(top: 4.h),
                    decoration: const BoxDecoration(
                      gradient: AppGradients.Projectgradient,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chatRooms')
                .where('participantIds', arrayContains: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 64.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[400]),
                      SizedBox(height: 16.h),
                      Text(
                        'No active chats yet',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Start chatting by visiting a nursery profile',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final chats = snapshot.data!.docs
                  .map((doc) => ChatRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                  .toList();

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Material(
                      elevation: 3,
                      shadowColor: isDark ? Colors.black26 : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.r),
                      color: isDark ? Colors.grey[850] : Colors.white,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        leading: CircleAvatar(
                          radius: 24.r,
                          backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                          backgroundImage: chat.nurseryImageUrl != null
                              ? NetworkImage(chat.nurseryImageUrl!)
                              : null,
                          child: chat.nurseryImageUrl == null
                              ? Text(
                            chat.nurseryName.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                          )
                              : null,
                        ),
                        title: Text(
                          chat.nurseryName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: isDark ? Colors.white : Colors.black,
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
                                  color: isDark
                                      ? (lastMessage.deleted ? Colors.grey[500] : Colors.grey[300])
                                      : (lastMessage.deleted ? Colors.grey[500] : Colors.black87),
                                  fontSize: 13.sp,
                                  height: 1.2,
                                ),
                              );
                            }
                            return Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark ? Colors.grey[500] : Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
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
                            if (snapshot.hasError) return const SizedBox();

                            final unreadCount = snapshot.data?.size ?? 0;
                            if (unreadCount > 0) {
                              return CircleAvatar(
                                radius: 10.r,
                                backgroundColor: Colors.blue[600],
                                child: Text(
                                  unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                        onTap: () {
                          _chatCubit.markMessagesAsRead(chat.id, userId);
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
                },
              );
            },
          ),
        ),
      ),
    );
  }
}