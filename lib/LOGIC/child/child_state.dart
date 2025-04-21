

import '../../DATA MODELS/Child Model/Child Model.dart';

abstract class ChildState {}

class ChildInitial extends ChildState {}

class ChildLoading extends ChildState {}

class ChildLoaded extends ChildState {
  final List<Child> children;

  ChildLoaded(this.children);
}

class ChildError extends ChildState {
  final String message;

  ChildError(this.message);
}
