import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../DATA MODELS/Notification/Notification.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _sub;

  NotificationCubit() : super(NotificationInitial()) {
    initNotifications();
  }

  void initNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(NotificationError('User not authenticated'));
      return;
    }

    _sub?.cancel();
    emit(NotificationLoading());

    _sub = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snap) {
      final notes = snap.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      emit(NotificationsLoaded(notes));
    }, onError: (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
