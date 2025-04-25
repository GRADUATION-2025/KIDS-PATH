abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsInitialized extends ChatState {}
class ChatJoinedSuccessfully extends ChatState {}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}