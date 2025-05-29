

import '../../DATA MODELS/Nursery model/Nursery Model.dart';

abstract class NurseryState {}

class NurseryInitial extends NurseryState {}

class NurseryLoading extends NurseryState {}

class NurseryLoaded extends NurseryState {
  final NurseryProfile nursery;
  NurseryLoaded(this.nursery);
}


class NurseryUpdating extends NurseryState {}

class NurseryError extends NurseryState {
  final String message;
  NurseryError(this.message);
}


class SubscriptionUpdateLoading extends NurseryState {}

class SubscriptionUpdateSuccess extends NurseryState {
  final String newStatus;
  SubscriptionUpdateSuccess(this.newStatus);
}

class SubscriptionUpdateError extends NurseryState {
  final String message;
  SubscriptionUpdateError(this.message);
}