import 'package:equatable/equatable.dart';

class ForgotPasswordState extends Equatable {
  @override
  List<Object> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;
  ForgotPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ForgotPasswordError extends ForgotPasswordState {
  final String error;
  ForgotPasswordError(this.error);

  @override
  List<Object> get props => [error];
}