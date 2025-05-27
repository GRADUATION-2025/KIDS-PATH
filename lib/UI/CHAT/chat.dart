import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../DATA MODELS/chatModel/massage.dart';
import '../../LOGIC/chat/cubit.dart';
import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import '../../THEME/theme_provider.dart';

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
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0.0;

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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          appBar: AppBar(
            elevation: 1,
            titleSpacing: 0,
            backgroundColor: isDark ? Colors.grey[850] : Colors.white,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.black,
            ),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.nurseryImageUrl != null
                      ? NetworkImage(widget.nurseryImageUrl!)
                      : null,
                  child: widget.nurseryImageUrl == null
                      ? Text(
                          widget.nurseryName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 10.w),
                Text(
                  widget.nurseryName,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  child: FutureBuilder<bool>(
                    future: _isNurseryFuture,
                    builder: (context, isNurserySnapshot) {
                      return StreamBuilder<List<Message>>(
                        stream: context.read<ChatCubit>().getMessages(widget.chatRoomId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || !isNurserySnapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: isDark ? Colors.blue[400] : Colors.blue,
                              ),
                            );
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
                                child: _buildMessageBubble(message, isMe),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              _buildMessageInput(userName, widget.userImage),
            ],
          ),
        ),
        if (_isUploading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress,
                    color: isDark ? Colors.blue[400] : Colors.blue,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageInput(String userName, String? userImage) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return SafeArea(
      child: Container(
        color: isDark ? Colors.grey[850] : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle,
                color: isDark ? Colors.blue[400] : Colors.blue,
                size: 32,
              ),
              onPressed: _showMediaPickerOptions,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.Projectgradient,
                  borderRadius: BorderRadius.circular(25.r),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write a comment',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(context, userName, userImage),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
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

  void _showMediaPickerOptions() {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.image,
                color: isDark ? Colors.blue[400] : Colors.blue,
              ),
              title: Text(
                'Upload Image',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.videocam,
                color: isDark ? Colors.blue[400] : Colors.blue,
              ),
              title: Text(
                'Upload Video',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _uploadAndSendMedia(image.path, 'image');
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _uploadAndSendMedia(video.path, 'video');
    }
  }

  Future<void> _uploadAndSendMedia(String filePath, String mediaType) async {
    _showUploadDialog();
    double lastProgress = 0.0;
    try {
      final ref = FirebaseStorage.instance.ref().child('chat_media/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = ref.putFile(File(filePath));
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / (event.totalBytes == 0 ? 1 : event.totalBytes);
        if (progress != lastProgress) {
          lastProgress = progress;
          _updateUploadDialog(progress);
        }
      });
      final snapshot = await uploadTask;
      final mediaUrl = await snapshot.ref.getDownloadURL();
      final thumbnailUrl = mediaType == 'video' ? await _generateThumbnail(filePath) : null;

      context.read<ChatCubit>().sendMessage(
        chatRoomId: widget.chatRoomId,
        senderId: widget.userId,
        senderName: FirebaseAuth.instance.currentUser!.displayName ?? 'User',
        senderImageUrl: FirebaseAuth.instance.currentUser!.photoURL,
        content: '',
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        thumbnailUrl: thumbnailUrl,
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload media: $e')));
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _UploadProgressDialog();
      },
    );
  }

  void _updateUploadDialog(double progress) {
    _UploadProgressDialog.updateProgress(context, progress);
  }

  Future<String?> _generateThumbnail(String videoPath) async {
    // Implement video thumbnail generation logic here
    return null;
  }

  void _showDeleteDialog(BuildContext context, Message message) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: Text(
          'Delete Message',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this message?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
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
            child: Text(
              'Delete',
              style: TextStyle(
                color: isDark ? Colors.red[400] : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> _getNurseryProfile(String nurseryId) async {
    final doc = await FirebaseFirestore.instance.collection('nurseries').doc(nurseryId).get();
    if (doc.exists) {
      final data = doc.data()!;
      return {
        'name': data['name'] ?? 'Nursery',
        'profileImageUrl': data['profileImageUrl'],
      };
    }
    return {'name': 'Nursery', 'profileImageUrl': null};
  }

  void _sendMessage(BuildContext context, String userName, String? userImage) async {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      String nameToSend = userName;
      String? imageToSend = userImage;

      final isNursery = await context.read<ChatCubit>().isUserNursery(widget.userId);
      if (isNursery) {
        final profile = await _getNurseryProfile(widget.userId);
        nameToSend = profile['name'];
        imageToSend = profile['profileImageUrl'];
      }

      context.read<ChatCubit>().sendMessage(
        chatRoomId: widget.chatRoomId,
        senderId: widget.userId,
        senderName: nameToSend,
        senderImageUrl: imageToSend,
        content: content,
      );
      _messageController.clear();
    }
  }

  void _showMediaViewer(String mediaUrl, String mediaType) {
    if (mediaType == 'image') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(),
            body: PhotoView(imageProvider: NetworkImage(mediaUrl)),
          ),
        ),
      );
    } else if (mediaType == 'video') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(videoUrl: mediaUrl),
        ),
      );
    }
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return GestureDetector(
      onTap: () {
        if (!message.deleted && message.mediaUrl != null) {
          _showMediaViewer(message.mediaUrl!, message.mediaType!);
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
                ? isDark ? Colors.grey[800] : Colors.grey[200]
                : isMe
                ? null
                : isDark ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
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
                      radius: 16.r,
                      backgroundImage: message.senderImageUrl != null
                          ? NetworkImage(message.senderImageUrl!)
                          : null,
                      child: message.senderImageUrl == null
                          ? Text(
                              message.senderName.isNotEmpty
                                  ? message.senderName.substring(0, 1).toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              if (!isMe && !message.deleted) const SizedBox(height: 4),
              if (message.mediaUrl != null && !message.deleted)
                _buildMediaPreview(message),
              Text(
                message.deleted
                    ? 'This message was deleted'
                    : message.content,
                style: TextStyle(
                  color: message.deleted
                      ? isDark ? Colors.grey[400] : Colors.grey[600]
                      : isMe
                      ? Colors.white
                      : isDark ? Colors.white : Colors.black,
                  fontStyle: message.deleted ? FontStyle.italic : null,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: message.deleted
                        ? isDark ? Colors.grey[400] : Colors.grey[500]
                        : isMe
                        ? Colors.white70
                        : isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(Message message) {
    if (message.mediaType == 'image') {
      return CachedNetworkImage(
        imageUrl: message.mediaUrl!,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else if (message.mediaType == 'video') {
      return Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: message.thumbnailUrl ?? message.mediaUrl!,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          const Icon(Icons.play_circle_filled, color: Colors.white, size: 50),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: Chewie(controller: _chewieController),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}

class _UploadProgressDialog extends StatefulWidget {
  static _UploadProgressDialogState? _dialogState;
  const _UploadProgressDialog({Key? key}) : super(key: key);

  static void updateProgress(BuildContext context, double progress) {
    _dialogState?._update(progress);
  }

  @override
  State<_UploadProgressDialog> createState() {
    _dialogState = _UploadProgressDialogState();
    return _dialogState!;
  }
}

class _UploadProgressDialogState extends State<_UploadProgressDialog> with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  void _update(double progress) {
    setState(() {
      _progress = progress;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90.w,
                  height: 90.h,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.blue[400]! : Colors.blueAccent),
                  ),
                ),
                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
                  child: Icon(
                    Icons.cloud_upload_rounded,
                    color: isDark ? Colors.blue[400] : Colors.blueAccent,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}