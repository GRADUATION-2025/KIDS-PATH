import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../DATA MODELS/Notification/Notification.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _subscription;

  NotificationCubit() : super(NotificationInitial()) {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      emit(NotificationError('User not authenticated'));
      return;
    }

    _subscription?.cancel();
    emit(NotificationLoading());

    _subscription = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      emit(NotificationsLoaded(notifications));
    }, onError: (error) {
      emit(NotificationError('Failed to load notifications: $error'));
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    final updatedNotifications = currentState.notifications
        .where((notification) => notification.id != notificationId)
        .toList();

    // Optimistic update
    emit(NotificationsLoaded(updatedNotifications));

    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (error) {
      // Revert on error
      emit(NotificationsLoaded(currentState.notifications));
      throw Exception('Failed to delete notification: $error');
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}