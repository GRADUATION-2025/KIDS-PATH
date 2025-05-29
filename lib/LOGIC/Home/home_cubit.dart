import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../DATA MODELS/search filter/filter.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _nurseriesSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  String? _currentUserId;

  HomeCubit() : super(HomeInitial()) {
    _initialize();
  }

  @override
  Future<void> close() {
    _nurseriesSubscription?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> _initialize() async {
    try {
      emit(HomeLoading());

      // Initialize user data first
      await _initializeUserData();

      // Then load nurseries
      await _loadNurseries();

      // Setup real-time listeners
      _setupListeners();
    } catch (e) {
      debugPrint('Initialization error: $e');
      emit(NurseryHomeError('Failed to initialize data'));
    }
  }

  Future<void> _initializeUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(HomeLoaded(
        nurseries: [],
        popularNurseries: [],
        topRatedNurseries: [],
        userName: 'Guest',
        profileImageUrl: null,
      ));
      return;
    }

    _currentUserId = user.uid;
    try {
      final userDoc = await _firestore.collection('parents').doc(_currentUserId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        emit((state as HomeLoading).copyWith(
          userName: data?['name'] ?? 'Guest',
          profileImageUrl: data?['profileImageUrl'],
        ));
      }
    } catch (e) {
      debugPrint('User data loading error: $e');
      throw Exception('Failed to load user data');
    }
  }

////////search filter//////
//   Future<void> loadFilteredNurseries(FilterParams filters) async {
//     emit(HomeLoading());
//     try {
//       Query query = _firestore.collection('nurseries');
//
//       if (filters.priceRange != null) {
//         query = query
//             .where('price', isGreaterThanOrEqualTo: filters.priceRange!.start)
//             .where('price', isLessThanOrEqualTo: filters.priceRange!.end);
//       }
//
//       if (filters.minRating != null) {
//         query = query.where('rating', isGreaterThanOrEqualTo: filters.minRating);
//       }
//
//       if (filters.ageGroup != null) {
//         query = query.where('ageGroups', arrayContains: filters.ageGroup);
//       }
//
//       final nurseriesQuery = await query.get();
//       final nurseries = nurseriesQuery.docs.map(_mapToNurseryProfile).toList();
//
//       emit(HomeLoaded(
//         nurseries: nurseries,
//         popularNurseries: nurseries,
//         topRatedNurseries: nurseries,
//         userName: (state as HomeLoading).userName,
//         profileImageUrl: (state as HomeLoading).profileImageUrl,
//       ));
//     } catch (e) {
//       emit(NurseryHomeError('Filter error: ${e.toString()}'));
//     }
//   }

///////////------/////////////////

  Future<void> _loadNurseries() async {
    try {
      final nurseriesQuery = await _firestore.collection('nurseries').get();
      final nurseries = nurseriesQuery.docs.map((doc) => _mapToNurseryProfile(doc)).toList();

      if (state is HomeLoading) {
        final loadingState = state as HomeLoading;
        emit(HomeLoaded(
          nurseries: nurseries,
          popularNurseries: _getPopularNurseries(nurseries),
          topRatedNurseries: await getTopRatedNurseries(nurseries),
          userName: loadingState.userName,
          profileImageUrl: loadingState.profileImageUrl,
        ));
      }
    } catch (e) {
      debugPrint('Nurseries loading error: $e');
      throw Exception('Failed to load nurseries');
    }
  }

  NurseryProfile _mapToNurseryProfile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Validate coordinates
    GeoPoint coordinates;
    if (data['Coordinates'] != null && data['Coordinates'] is GeoPoint) {
      coordinates = data['Coordinates'] as GeoPoint;
      // Validate that coordinates are not (0,0)
      if (coordinates.latitude == 0.0 && coordinates.longitude == 0.0) {
        coordinates = GeoPoint(0.0, 0.0); // Mark as invalid
      }
    } else {
      coordinates = GeoPoint(0.0, 0.0); // Mark as invalid
    }

    return NurseryProfile(
        uid: doc.id,
        name: data['name'] ?? 'Unnamed Nursery',
        profileImageUrl: data['profileImageUrl'],
        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        description: data['description'] ?? '',
        price: data['price'] ?? '',
        hours: data['hours'] ?? '',
        language: data['language'] ?? '',
        programs: List<String>.from(data['programs'] ?? []),
        phoneNumber: data['phoneNumber'] ?? '',
        email: data['email'] ?? '',
        age: data['age'] ?? '',
        role: data['role'] ?? '',
        schedules: List<String>.from(data['schedules'] ?? []),
        calendar: data['calendar'] ?? '',
        ownerId: data['ownerId'] ?? '',
        location: data['location'] ?? '',
        Coordinates: coordinates,
        averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
        totalRatings: (data['totalRatings'] as num?)?.toInt() ?? 0,
        subscriptionStatus: data['subscriptionStatus'] ?? 'regular'
    );
  }

  List<NurseryProfile> _getPopularNurseries(List<NurseryProfile> allNurseries) {
    // Filter only premium nurseries
    final premiumNurseries = allNurseries.where((nursery) =>
    nursery.subscriptionStatus == 'premium'
    ).toList();

    // If we have premium nurseries, return them shuffled
    if (premiumNurseries.isNotEmpty) {
      return List<NurseryProfile>.from(premiumNurseries)..shuffle();
    }

    // If no premium nurseries, return empty list
    return [];
  }

  Future<List<NurseryProfile>> getTopRatedNurseries(List<NurseryProfile> allNurseries) async {
    final ratingsSnapshot = await FirebaseFirestore.instance.collection('ratings').get();

    // Group ratings by nurseryId
    final Map<String, List<int>> ratingsMap = {};

    for (var doc in ratingsSnapshot.docs) {
      final String nurseryId = doc['nurseryId'];
      final int rating = doc['rating'];

      if (!ratingsMap.containsKey(nurseryId)) {
        ratingsMap[nurseryId] = [];
      }
      ratingsMap[nurseryId]!.add(rating);
    }

    // Calculate average rating per nurseryId
    final Map<String, double> avgRatings = {};
    ratingsMap.forEach((nurseryId, ratings) {
      final average = ratings.reduce((a, b) => a + b) / ratings.length;
      avgRatings[nurseryId] = average;
    });

    // Filter nurseries with average rating == 5
    final topRatedNurseries = allNurseries.where((nursery) {
      final avg = avgRatings[nursery.uid];
      return avg != null && avg > 0.0;
    }).toList();

    // Sort by descending rating (though all are 5.0 here)
    topRatedNurseries.sort((a, b) {
      final avgA = avgRatings[a.uid]!;
      final avgB = avgRatings[b.uid]!;
      return avgB.compareTo(avgA);
    });

    return topRatedNurseries;
  }

  void _setupListeners() {
    if (_currentUserId == null) return;

    _userSubscription = _firestore.collection('parents').doc(_currentUserId).snapshots().listen(
          (snapshot) {
        if (snapshot.exists && state is HomeLoaded) {
          final data = snapshot.data();
          final currentState = state as HomeLoaded;
          emit(currentState.copyWith(
            userName: data?['name'] ?? 'Guest',
            profileImageUrl: data?['profileImageUrl'],
          ));
        }
      },
      onError: (e) => debugPrint('User data listener error: $e'),
    );

    _nurseriesSubscription = _firestore.collection('nurseries').snapshots().listen(
          (snapshot) async {
        if (state is HomeLoaded) {
          final nurseries = snapshot.docs.map(_mapToNurseryProfile).toList();
          final currentState = state as HomeLoaded;
          emit(currentState.copyWith(
            nurseries: nurseries,
            popularNurseries: _getPopularNurseries(nurseries),
            topRatedNurseries: await getTopRatedNurseries(nurseries),
          ));
        }
      },
      onError: (e) => debugPrint('Nurseries listener error: $e'),
    );
  }

  Future<void> refreshData() async {
    await _initialize();
  }
}