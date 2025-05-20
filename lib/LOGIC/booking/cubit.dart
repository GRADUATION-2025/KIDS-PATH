import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidspath/LOGIC/booking/state.dart';
import '../../DATA MODELS/bookingModel/bookingModel.dart';
import '../../DATA MODELS/Child Model/Child Model.dart';

class BookingCubit extends Cubit<BookingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _bookingsSubscription;
  bool _isProcessing = false;

  BookingCubit() : super(BookingInitial());

  /// Stream bookings for parent/nursery
  void initBookingsStream({required bool isNursery}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(BookingError('User not authenticated'));
      return;
    }
    _bookingsSubscription?.cancel();
    emit(BookingLoading());
    _bookingsSubscription = _firestore
        .collection('bookings')
        .where(isNursery ? 'nurseryId' : 'parentId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      final list = snap.docs.map((d) => Booking.fromFirestore(d)).toList();
      emit(BookingsLoaded(list, isNursery));
    }, onError: (e) {
      emit(BookingError('Failed to load bookings: $e'));
    });
  }

  /// Create booking and notify both sides
  Future<void> createBooking({
    required DateTime dateTime,
    required String nurseryId,
    required String nurseryName,
    required Child child,
  }) async {
    if (_isProcessing) return;
    _isProcessing = true;
    emit(BookingLoading());
    try {
      final user = _auth.currentUser!;
      final parentId = user.uid;

      final existing = await _firestore
          .collection('bookings')
          .where('parentId', isEqualTo: parentId)
          .where('nurseryId', isEqualTo: nurseryId)
          .where('childId', isEqualTo: child.id)
          .where('status', isEqualTo: 'pending')
          .get();
      if (existing.docs.isNotEmpty) {
        emit(BookingError('Existing pending booking for this child'));
        return;
      }

      final parentDoc = await _firestore.collection('parents').doc(parentId).get();
      final nurseryDoc = await _firestore.collection('nurseries').doc(nurseryId).get();

      final ref = _firestore.collection('bookings').doc();
      final booking = Booking(
          id: ref.id,
          parentId: parentId,
          nurseryId: nurseryId,
          parentName: parentDoc['name'] ?? 'Parent',
          parentEmail: parentDoc['email'] ?? '',
          parentProfileImage: parentDoc['profileImageUrl'],
          nurseryName: nurseryName,
          nurseryProfileImage: nurseryDoc['profileImageUrl'],
          dateTime: dateTime,
          status: 'pending',
          createdAt: Timestamp.now(),
          updatedAt: null,
          childId: child.id,
          childName: child.name,
          childAge: child.age,
          childGender: child.gender,
          rated: false
      );
      await ref.set(booking.toMap());
      emit(BookingCreated());

      await _createNotification(
        userId: parentId,
        type: 'booking',
        title: 'Booking Request Sent',
        message: 'Your booking request for ${child.name} has been sent to $nurseryName',
        bookingId: ref.id,
      );
      await _createNotification(
        userId: nurseryId,
        type: 'booking',
        title: 'New Booking Request',
        message: 'New booking request from ${parentDoc['name']} for ${child.name}',
        bookingId: ref.id,
      );
    } catch (e) {
      emit(BookingError('Booking failed: $e'));
    } finally {
      _isProcessing = false;
    }
  }

  /// Accept/Rej/Confirm and notify
  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      final b = Booking.fromFirestore(doc);

      String title, message;
      if (status == 'accepted') {
        title   = 'Booking Accepted';
        message = 'Your booking for ${b.childName} at ${b.nurseryName} was accepted';
      } else if (status == 'rejected') {
        title   = 'Booking Rejected';
        message = 'Your booking for ${b.childName} at ${b.nurseryName} was rejected';
      } else if (status == 'confirmed') {
        title   = 'Booking Confirmed';
        message = 'Your booking for ${b.childName} at ${b.nurseryName} was confirmed';
      } else {
        title   = 'Booking Updated';
        message = 'Your booking for ${b.childName} at ${b.nurseryName} is now "$status"';
      }

      await _createNotification(
        userId: b.parentId,
        type: 'booking',
        title: title,
        message: message,
        bookingId: bookingId,
      );
      // optional nursery self-notify
      await _createNotification(
        userId: b.nurseryId,
        type: 'booking',
        title: 'You $title',
        message: 'You have $title booking for ${b.childName}.',
        bookingId: bookingId,
      );
      if (state is BookingsLoaded) {
        initBookingsStream(isNursery: (state as BookingsLoaded).isNurseryView);
      }
    } catch (e) {
      emit(BookingError('Update failed: $e'));
    } finally {
      _isProcessing = false;
    }
  }

  /// Cancel booking and notify parent (and nursery)
  Future<void> cancelBooking(String bookingId) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!doc.exists) throw Exception('Booking not found');
      final data = doc.data()!;
      final parentId    = data['parentId']   as String;
      final nurseryId   = data['nurseryId']  as String;
      final childName   = data['childName']  as String;
      final nurseryName = data['nurseryName']as String;

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _createNotification(
        userId: parentId,
        type: 'booking',
        title: 'Booking Cancelled',
        message: 'Your booking for $childName at $nurseryName has been cancelled.',
        bookingId: bookingId,
      );
      await _createNotification(
        userId: nurseryId,
        type: 'booking',
        title: 'Booking Cancelled',
        message: '$childName\'s parent cancelled the booking.',
        bookingId: bookingId,
      );

      if (state is BookingsLoaded) {
        initBookingsStream(isNursery: (state as BookingsLoaded).isNurseryView);
      }
    } catch (e) {
      emit(BookingError('Cancellation failed: $e'));
    } finally {
      _isProcessing = false;
    }
  }

  /// Write notification doc
  Future<void> _createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? bookingId,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'bookingId': bookingId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> submitRating({
    required String nurseryId,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      final user = _auth.currentUser!;

      // Validate rating
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1-5 stars');
      }

      // Store rating
      await _firestore.collection('ratings').add({
        'nurseryId': nurseryId,
        'parentId': user.uid,
        'rating': rating,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'bookingId': bookingId,
      });
      await FirebaseFirestore.instance
          .collection('nurseries')
          .doc(nurseryId)
          .update({
        'rating': rating,
      });

      // Update specific booking as rated
      await _firestore.collection('bookings').doc(bookingId).update({
        'rated': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh bookings list
      if (state is BookingsLoaded) {
        final currentState = state as BookingsLoaded;
        initBookingsStream(isNursery: currentState.isNurseryView);
      }

    } catch (e) {
      emit(BookingError('Rating submission failed: $e'));
    }
  }
}