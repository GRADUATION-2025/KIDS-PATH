import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidspath/SERVICES/one_signal_service.dart';
import '../../DATA MODELS/Notification/Notification.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final OneSignalService _oneSignalService = OneSignalService();
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
        .listen((snapshot) async {
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      if (notifications.isNotEmpty) {
        final latest = notifications.first;
        if (!latest.isRead) {
          await _sendPushNotification(
            title: latest.title,
            message: latest.message,
            data: {
              'type': latest.type,
              'childName': latest.childName,
              'bookingId': latest.bookingId,
            },
          );
        }
      }

      emit(NotificationsLoaded(notifications));
    }, onError: (error) {
      emit(NotificationError('Failed to load notifications: $error'));
    });
  }

  Future<void> _sendPushNotification({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _oneSignalService.sendTestNotification(
        title: title,
        message: message,
        data: data,
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    final updatedNotifications = currentState.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    emit(NotificationsLoaded(updatedNotifications));

    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      emit(NotificationsLoaded(currentState.notifications));
      throw Exception('Failed to mark notification as read: $error');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    final updatedNotifications = currentState.notifications
        .where((notification) => notification.id != notificationId)
        .toList();

    emit(NotificationsLoaded(updatedNotifications));

    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (error) {
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