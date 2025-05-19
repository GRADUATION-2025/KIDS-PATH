import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../DATA MODELS/Parent Model/Parent Model.dart';
import 'parent_state.dart';

class ParentCubit extends Cubit<ParentState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ParentCubit() : super(ParentInitial());

  // Helper method to ensure parent document exists in both collections
  Future<void> _ensureParentDocument(String uid) async {
    final parentRef = _firestore.collection('parents').doc(uid);
    final doc = await parentRef.get();

    if (!doc.exists) {
      // Get basic user data from users collection
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data()!;
      final newParent = Parent(
        uid: uid,
        name: userData['name'] ?? 'New Parent',
        email: userData['email'] ?? '',
        role: userData['role'] ?? '',
        phoneNumber: userData['phoneNumber'] ?? '',
        paymentCards: [],
        location: 'location',
        profileImageUrl: userData['profileImageUrl'],
      );

      await parentRef.set(newParent.toMap());
    }
  }

  // Fetch parent data from parents collection
  Future<void> fetchParentData(String uid) async {
    try {
      emit(ParentLoading());

      await _ensureParentDocument(uid);

      final parentDoc = await _firestore.collection('parents').doc(uid).get();
      final parent = Parent.fromMap(parentDoc.data()!);
      emit(ParentLoaded(parent));
    } catch (e) {
      emit(ParentError('Failed to fetch parent data: ${e.toString()}'));
    }
  }

  // Create new parent profile in parents collection
  Future<void> createParentProfile(String uid) async {
    try {
      emit(ParentLoading());

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        emit(ParentError('User not found'));
        return;
      }

      final userData = userDoc.data()!;
      final newParent = Parent(
        uid: uid,
        name: userData['name'] ?? 'New Parent',
        email: userData['email'] ?? '',
        role: userData['role'] ?? '',
        phoneNumber: userData['phoneNumber'] ?? '',
        paymentCards: [],
        location: 'Location',
        profileImageUrl: userData['profileImageUrl'],
      );

      await _firestore.collection('parents').doc(uid).set(newParent.toMap());
      emit(ParentLoaded(newParent));
    } catch (e) {
      emit(ParentError('Failed to create parent profile: ${e.toString()}'));
    }
  }

  // Update parent name only in parents collection
  Future<void> updateParentName(String uid, String newName) async {
    try {
      emit(ParentLoading());

      await _ensureParentDocument(uid);

      await _firestore.collection('parents').doc(uid).update({
        'name': newName,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchParentData(uid);
    } catch (e) {
      emit(ParentError('Failed to update name: ${e.toString()}'));
      if (state is ParentLoaded) {
        emit(state as ParentLoaded);
      }
    }
  }

  // Update phone number only in parents collection
  Future<void> updatePhoneNumber(String uid, String newPhoneNumber) async {
    try {
      emit(ParentLoading());

      await _ensureParentDocument(uid);

      await _firestore.collection('parents').doc(uid).update({
        'phoneNumber': newPhoneNumber,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchParentData(uid);
    } catch (e) {
      emit(ParentError('Failed to update phone number: ${e.toString()}'));
      if (state is ParentLoaded) {
        emit(state as ParentLoaded);
      }
    }
  }

  // Update parent location
  Future<void> updateLocation(String uid, String newLocation) async {
    try {
      emit(ParentLoading());

      await _ensureParentDocument(uid);

      await _firestore.collection('parents').doc(uid).update({
        'location': newLocation,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchParentData(uid);
    } catch (e) {
      emit(ParentError('Failed to update location: ${e.toString()}'));
      if (state is ParentLoaded) {
        emit(state as ParentLoaded);
      }
    }
  }

  // Update profile image only in parents collection
  Future<void> updateProfileImage(String uid, String imageUrl) async {
    try {
      emit(ParentLoading());

      await _ensureParentDocument(uid);

      await _firestore.collection('parents').doc(uid).update({
        'profileImageUrl': imageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchParentData(uid);
    } catch (e) {
      emit(ParentError('Failed to update profile image: ${e.toString()}'));
      if (state is ParentLoaded) {
        emit(state as ParentLoaded);
      }
    }
  }

  // Add payment card to parents collection
  Future<void> addPaymentCard(String uid, String cardId) async {
    try {
      emit(ParentLoading());

      await _ensureParentDocument(uid);

      await _firestore.collection('parents').doc(uid).update({
        'paymentCards': FieldValue.arrayUnion([cardId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchParentData(uid);
    } catch (e) {
      emit(ParentError('Failed to add payment card: ${e.toString()}'));
      if (state is ParentLoaded) {
        emit(state as ParentLoaded);
      }
    }
  }

  // Remove payment card from parents collection
  Future<void> removePaymentCard(String uid, String cardId) async {
    try {
      emit(ParentLoading());

      await _ensureParentDocument(uid);

      await _firestore.collection('parents').doc(uid).update({
        'paymentCards': FieldValue.arrayRemove([cardId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchParentData(uid);
    } catch (e) {
      emit(ParentError('Failed to remove payment card: ${e.toString()}'));
      if (state is ParentLoaded) {
        emit(state as ParentLoaded);
      }
    }
  }

  // Generic update method for multiple fields
  Future<void> updateParentData({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
    required String location,
    List<String>? paymentCards,
    String? profileImageUrl,
  }) async {
    try {
      emit(ParentLoading());

      await _ensureParentDocument(uid);

      final updateData = {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'location': location,
        if (paymentCards != null) 'paymentCards': paymentCards,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Update in parents collection
      await _firestore.collection('parents').doc(uid).update(updateData);

      // Only update email in users collection (removed name and lastUpdated)
      await _firestore.collection('users').doc(uid).update({
        'email': email,
      });

      await fetchParentData(uid);
    } catch (e) {
      emit(ParentError('Failed to update parent data: ${e.toString()}'));
      if (state is ParentLoaded) {
        emit(state as ParentLoaded);
      }
    }
  }
}