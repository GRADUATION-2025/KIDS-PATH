// Updated BookingCubit
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

  void initBookingsStream({required bool isNursery}) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _bookingsSubscription?.cancel();

    _bookingsSubscription = _firestore
        .collection('bookings')
        .where(isNursery ? 'nurseryId' : 'parentId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      final bookings = snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      emit(BookingsLoaded(bookings));
    });
  }

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

      // Check for existing bookings for same child and nursery
      final existing = await _firestore
          .collection('bookings')
          .where('parentId', isEqualTo: user.uid)
          .where('nurseryId', isEqualTo: nurseryId)
          .where('childId', isEqualTo: child.id)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        emit(BookingError('You already have a pending booking for this child'));
        return;
      }

      // Get parent and nursery data
      final parentDoc = await _firestore.collection('parents').doc(user.uid).get();
      final parentData = parentDoc.data() as Map<String, dynamic>;

      final nurseryDoc = await _firestore.collection('nurseries').doc(nurseryId).get();
      final nurseryData = nurseryDoc.data() as Map<String, dynamic>;

      final booking = Booking(
        id: '',
        parentId: user.uid,
        nurseryId: nurseryId,
        parentName: parentData['name'] ?? 'Parent',
        parentEmail: parentData['email'] ?? '',
        parentProfileImage: parentData['profileImageUrl'],
        nurseryName: nurseryName,
        nurseryProfileImage: nurseryData['profileImageUrl'],
        dateTime: dateTime,
        status: 'pending',
        createdAt: Timestamp.now(),
        updatedAt: null,
        childId: child.id,
        childName: child.name,
        childAge: child.age,
        childGender: child.gender,
      );

      await _firestore.collection('bookings').add(booking.toMap());
      emit(BookingCreated());
    } catch (e) {
      emit(BookingError('Booking failed: ${e.toString()}'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (_isProcessing) return;
    _isProcessing = true;
    emit(BookingLoading());

    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      emit(BookingStatusUpdated());
    } catch (e) {
      emit(BookingError('Update failed: ${e.toString()}'));
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }
}
