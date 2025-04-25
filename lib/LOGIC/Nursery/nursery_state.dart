

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