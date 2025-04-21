
import 'package:firebase_auth/firebase_auth.dart';

abstract class SignUpStates {}

class SignUpInitial extends SignUpStates {}

class SignUpLoadingState extends SignUpStates {}

class SignupSuccessState extends SignUpStates {
  final User user;
  SignupSuccessState(this.user);
}

class SignUpErrorState extends SignUpStates {
  final String errorMessage;
  SignUpErrorState(this.errorMessage);
}