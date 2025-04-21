

import '../../DATA MODELS/Parent Model/Parent Model.dart';

abstract class ParentState {}

class ParentInitial extends ParentState {}

class ParentLoading extends ParentState {} // Add this line for loading state

class ParentLoaded extends ParentState {
  final Parent parent;
  ParentLoaded(this.parent);
}

class ParentError extends ParentState {
  final String message;
  ParentError(this.message);
}