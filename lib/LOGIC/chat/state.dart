import '../../DATA MODELS/chatModel/massage.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsInitialized extends ChatState {}

class ChatJoinedSuccessfully extends ChatState {}

class ChatNotificationReceived extends ChatState {
  final String title;
  final String message;
  final Map<String, dynamic> data;

  ChatNotificationReceived({
    required this.title,
    required this.message,
    required this.data,
  });
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
class NewMessageReceived extends ChatState {
  final Message message;
  NewMessageReceived(this.message);
}