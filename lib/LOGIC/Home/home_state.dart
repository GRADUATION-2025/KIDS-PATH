import 'package:flutter/material.dart';

import '../../DATA MODELS/Nursery model/Nursery Model.dart';


@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  final String? userName;
  final String? profileImageUrl;

  HomeLoading({this.userName, this.profileImageUrl});

  HomeLoading copyWith({
    String? userName,
    String? profileImageUrl,
  }) {
    return HomeLoading(
      userName: userName ?? this.userName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class HomeLoaded extends HomeState {
  final List<NurseryProfile> nurseries;
  final List<NurseryProfile> popularNurseries;
  final List<NurseryProfile> topRatedNurseries;
  final String? userName;
  final String? profileImageUrl;

  HomeLoaded({
    required this.nurseries,
    required this.popularNurseries,
    required this.topRatedNurseries,
    this.userName,
    this.profileImageUrl,
  });

  HomeLoaded copyWith({
    List<NurseryProfile>? nurseries,
    List<NurseryProfile>? popularNurseries,
    List<NurseryProfile>? topRatedNurseries,
    String? userName,
    String? profileImageUrl,
  }) {
    return HomeLoaded(
      nurseries: nurseries ?? this.nurseries,
      popularNurseries: popularNurseries ?? this.popularNurseries,
      topRatedNurseries: topRatedNurseries ?? this.topRatedNurseries,
      userName: userName ?? this.userName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class NurseryHomeEmpty extends HomeState {
  final String message;
  NurseryHomeEmpty(this.message);
}

class NurseryHomeError extends HomeState {
  final String message;
  NurseryHomeError(this.message);
}