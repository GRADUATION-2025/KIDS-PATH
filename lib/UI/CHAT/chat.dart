

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../DATA MODELS/chatModel/massage.dart';
import '../../LOGIC/chat/cubit.dart';
import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String nurseryName;
  final String? nurseryImageUrl;
  final String userId;
  final String? userImage;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.nurseryName,
    this.nurseryImageUrl,
    required this.userId,
    this.userImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<bool> _isNurseryFuture;

  @override
  void initState() {
    super.initState();
    _isNurseryFuture = context.read<ChatCubit>().isUserNursery(widget.userId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().markMessagesAsRead(widget.chatRoomId, widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = FirebaseAuth.instance.currentUser!.displayName ?? 'User';
    final userImage = FirebaseAuth.instance.currentUser!.photoURL;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.nurseryImageUrl != null
                  ? NetworkImage(widget.nurseryImageUrl!)
                  : null,
              child: widget.nurseryImageUrl == null
                  ? Text(widget.nurseryName.substring(0, 1).toUpperCase())
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.nurseryName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<bool>(
              future: _isNurseryFuture,
              builder: (context, isNurserySnapshot) {
                return StreamBuilder<List<Message>>(
                  stream: context.read<ChatCubit>().getMessages(widget.chatRoomId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !isNurserySnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final isNursery = isNurserySnapshot.data!;
                    final messages = snapshot.data!;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients && messages.isNotEmpty) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == widget.userId;

                        return GestureDetector(
                          onLongPress: () {
                            if (message.canDelete(widget.userId, isNursery)) {
                              _showDeleteDialog(context, message);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                gradient: message.deleted
                                    ? null
                                    : isMe
                                    ? AppGradients.Projectgradient
                                    : null,
                                color: message.deleted
                                    ? Colors.grey[200]
                                    : isMe
                                    ? null
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                                  bottomRight: Radius.circular(isMe ? 0 : 16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMe && !message.deleted)
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundImage: message.senderImageUrl != null
                                              ? NetworkImage(message.senderImageUrl!)
                                              : null,
                                          child: message.senderImageUrl == null
                                              ? Text(message.senderName.isNotEmpty
                                              ? message.senderName.substring(0, 1).toUpperCase()
                                              : '?')
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          message.senderName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (!isMe && !message.deleted) const SizedBox(height: 4),
                                  Text(
                                    message.deleted
                                        ? 'This message was deleted'
                                        : message.content,
                                    style: TextStyle(
                                      color: message.deleted
                                          ? Colors.grey[600]
                                          : isMe
                                          ? Colors.white
                                          : Colors.black,
                                      fontStyle: message.deleted ? FontStyle.italic : null,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      _formatTime(message.timestamp),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: message.deleted
                                            ? Colors.grey[500]
                                            : isMe
                                            ? Colors.white70
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(userName, userImage),
        ],
      ),
    );
  }

  Widget _buildMessageInput(String userName, String? userImage) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.Projectgradient,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(context, userName, userImage),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.Projectgradient,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _sendMessage(context, userName, userImage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final isNursery = await _isNurseryFuture;
              await context.read<ChatCubit>().deleteMessage(
                chatRoomId: widget.chatRoomId,
                messageId: message.id,
                currentUserId: widget.userId,
                isCurrentUserNursery: isNursery,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage(BuildContext context, String userName, String? userImage) {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      context.read<ChatCubit>().sendMessage(
        chatRoomId: widget.chatRoomId,
        senderId: widget.userId,
        senderName: userName,
        senderImageUrl: userImage,
        content: content,
      );
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}