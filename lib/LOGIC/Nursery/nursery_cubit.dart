import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../PremiumUpgrade/sub man.dart';
import 'nursery_state.dart';

class NurseryCubit extends Cubit<NurseryState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NurseryCubit() : super(NurseryInitial());

  // Helper method to ensure nursery document exists
  Future<void> _ensureNurseryDocument(String uid) async {
    final nurseryRef = _firestore.collection('nurseries').doc(uid);
    final doc = await nurseryRef.get();

    if (!doc.exists) {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data()!;
      final newNursery = NurseryProfile(
        uid: uid,
        name: userData['name'] ?? "",
        profileImageUrl: userData['profileImageUrl'],
        rating: 0.0,
        description: '',
        price: 'Contact for pricing',
        totalRatings:0 ,
        averageRating:0.0 ,
        hours: '',
        language: "",
        age: "",
        programs: ['General Program'],
        phoneNumber: userData['phoneNumber'] ?? '', // Initialize phone number
        email: userData['email'] ?? '',
        role: 'Nursery',
        schedules: ['Full-time'],
        calendar: '',
        location: "",
        Coordinates: userData['Coordinates'] != null
            ? userData['Coordinates'] as GeoPoint
            : GeoPoint(0.0, 0.0),
        ownerId: uid,

      );

      await nurseryRef.set(newNursery.toMap());
    }
  }

  // Fetch nursery data
  Future<void> fetchNurseryData(String uid) async {
    try {
      if (uid.isEmpty) {
        emit(NurseryError('Invalid user ID'));
        return;
      }

      emit(NurseryLoading());
      await _ensureNurseryDocument(uid);

      final nurseryDoc = await _firestore.collection('nurseries').doc(uid).get();
      if (!nurseryDoc.exists) {
        throw Exception('Nursery document not found');
      }

      final nursery = NurseryProfile.fromMap(nurseryDoc.data()!);
      emit(NurseryLoaded(nursery));
    } catch (e) {
      emit(NurseryError('Failed to fetch nursery data: ${e.toString()}'));
    }
  }

  // Create new nursery profile
  Future<void> createNurseryProfile(String uid) async {
    try {
      emit(NurseryLoading());

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        emit(NurseryError('User not found'));
        return;
      }

      final userData = userDoc.data()!;
      final newNursery = NurseryProfile(
          uid: uid,
          name: userData['name'] ?? "",
          profileImageUrl: userData['profileImageUrl'],
          rating: 0.0,
          description: "",
          age: "",
          price: '',
          hours: '',
          language: '',
          programs: ['General Program'],
          phoneNumber: userData['phoneNumber'] ?? '', // Initialize phone number
          email: userData['email'] ?? '',
          role: 'Nursery',
          schedules: ['Full-time'],
          calendar: '',
          location: "",
          Coordinates: GeoPoint(0, 0),
          ownerId: uid,
          averageRating: 0.0,
          totalRatings: 0

      );

      await _firestore.collection('nurseries').doc(uid).set(newNursery.toMap());
      emit(NurseryLoaded(newNursery));
    } catch (e) {
      emit(NurseryError('Failed to create nursery profile: ${e.toString()}'));
    }
  }

  // Update all nursery data
  Future<void> updateNurseryData({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
    required String description,
    required String price,
    required String hours,
    required String age,
    required String language,
    required List<String> programs,
    required List<String> schedules,
    String? calendar,
    String? profileImageUrl,
  }) async {
    try {
      emit(NurseryLoading());

      await _ensureNurseryDocument(uid);

      final updateData = {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber, // Include phone number
        'description': description,
        'price': price,
        'hours': hours,
        'age': age,
        'language': language,
        'programs': programs,
        'schedules': schedules,
        if (calendar != null) 'calendar': calendar,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('nurseries').doc(uid).update(updateData);

      // Update user collection with only specific fields
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'phoneNumber': phoneNumber, // Include phone number
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchNurseryData(uid);
    } catch (e) {
      emit(NurseryError('Failed to update nursery data: ${e.toString()}'));
      if (state is NurseryLoaded) {
        emit(state as NurseryLoaded);
      }
    }
  }

  // Update basic info
  Future<void> updateNurseryInfo({
    required String uid,
    required String name,
    required String description,
    required String price,
    required String hours,
    required String language,
  }) async {
    try {
      emit(NurseryLoading());

      await _ensureNurseryDocument(uid);

      await _firestore.collection('nurseries').doc(uid).update({
        'name': name,
        'description': description,
        'price': price,
        'hours': hours,
        'language': language,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchNurseryData(uid);
    } catch (e) {
      emit(NurseryError('Failed to update nursery info: ${e.toString()}'));
      if (state is NurseryLoaded) {
        emit(state as NurseryLoaded);
      }
    }
  }

  // Update contact info - with phone number fix
  Future<void> updateContactInfo({
    required String uid,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      emit(NurseryLoading());

      if (phoneNumber.isEmpty) {
        throw Exception('Phone number cannot be empty');
      }

      await _firestore.collection('nurseries').doc(uid).update({
        'email': email,
        'phoneNumber': phoneNumber,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(uid).update({
        'phoneNumber': phoneNumber,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchNurseryData(uid);
    } catch (e) {
      emit(NurseryError('Failed to update contact info: ${e.toString()}'));
      if (state is NurseryLoaded) {
        emit(state as NurseryLoaded);
      }
    }
  }

  // Update profile image
  Future<void> updateProfileImage(String uid, String imageUrl) async {
    try {
      emit(NurseryLoading());

      await _ensureNurseryDocument(uid);

      await _firestore.collection('nurseries').doc(uid).update({
        'profileImageUrl': imageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': imageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchNurseryData(uid);
    } catch (e) {
      emit(NurseryError('Failed to update profile image: ${e.toString()}'));
      if (state is NurseryLoaded) {
        emit(state as NurseryLoaded);
      }
    }
  }

  // Update programs
  Future<void> updatePrograms(String uid, List<String> programs) async {
    try {
      emit(NurseryLoading());

      await _ensureNurseryDocument(uid);

      await _firestore.collection('nurseries').doc(uid).update({
        'programs': programs,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchNurseryData(uid);
    } catch (e) {
      emit(NurseryError('Failed to update programs: ${e.toString()}'));
      if (state is NurseryLoaded) {
        emit(state as NurseryLoaded);
      }
    }
  }

  // Update schedules
  Future<void> updateSchedules(String uid, List<String> schedules) async {
    try {
      emit(NurseryLoading());

      await _ensureNurseryDocument(uid);

      await _firestore.collection('nurseries').doc(uid).update({
        'schedules': schedules,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchNurseryData(uid);
    } catch (e) {
      emit(NurseryError('Failed to update schedules: ${e.toString()}'));
      if (state is NurseryLoaded) {
        emit(state as NurseryLoaded);
      }
    }
  }

  // Update calendar
  Future<void> updateCalendar(String uid, String calendar) async {
    try {
      emit(NurseryLoading());

      await _ensureNurseryDocument(uid);

      await _firestore.collection('nurseries').doc(uid).update({
        'calendar': calendar,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchNurseryData(uid);
    } catch (e) {
      emit(NurseryError('Failed to update calendar: ${e.toString()}'));
      if (state is NurseryLoaded) {
        emit(state as NurseryLoaded);
      }
    }
  }

  Future<void> updateSubscriptionStatus({
    required String nurseryId,
    required String status,
  }) async {
    emit(SubscriptionUpdateLoading());
    try {
      await SubscriptionManager.updateSubscriptionStatus(
        nurseryId: nurseryId,
        status: status,
      );
      emit(SubscriptionUpdateSuccess(status));
    } catch (e) {
      emit(SubscriptionUpdateError(e.toString()));
    }
  }
}