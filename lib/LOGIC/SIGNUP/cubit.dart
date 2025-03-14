import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'state.dart';

class SignupCubit extends Cubit<SignUpStates> {
  final FirebaseAuth firebaseAuth;
  SignupCubit(this.firebaseAuth) : super(SignUpInitialState());

  Future<void> signup(String email, String password) async {
    emit(SignUpLoadingState());
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      emit(SignupSuccessState());
    } catch (e) {
      emit(SignUpErrorState(e.toString()));
    }
  }
}