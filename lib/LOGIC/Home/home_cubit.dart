import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../DATA MODELS/Nursery model/Nursery Model.dart';
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

  Future<void> _loadNurseries() async {
    try {
      final nurseriesQuery = await _firestore.collection('nurseries').get();
      final nurseries = nurseriesQuery.docs.map((doc) => _mapToNurseryProfile(doc)).toList();

      if (state is HomeLoading) {
        final loadingState = state as HomeLoading;
        emit(HomeLoaded(
          nurseries: nurseries,
          popularNurseries: _getPopularNurseries(nurseries),
          topRatedNurseries: _getTopRatedNurseries(nurseries),
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
      role: data['role'] ?? '',
      schedules: List<String>.from(data['schedules'] ?? []),
      calendar: data['calendar'] ?? '',
      ownerId: data['ownerId'] ?? '',
      location: ""
    );
  }

  List<NurseryProfile> _getPopularNurseries(List<NurseryProfile> allNurseries) {
    return List<NurseryProfile>.from(allNurseries)..shuffle();
  }

  List<NurseryProfile> _getTopRatedNurseries(List<NurseryProfile> allNurseries) {
    return List<NurseryProfile>.from(allNurseries)
      ..sort((a, b) => b.rating.compareTo(a.rating));
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
          (snapshot) {
        if (state is HomeLoaded) {
          final nurseries = snapshot.docs.map(_mapToNurseryProfile).toList();
          final currentState = state as HomeLoaded;
          emit(currentState.copyWith(
            nurseries: nurseries,
            popularNurseries: _getPopularNurseries(nurseries),
            topRatedNurseries: _getTopRatedNurseries(nurseries),
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


