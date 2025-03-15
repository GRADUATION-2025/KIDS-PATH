import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidspath/LOGIC/forget%20password/state.dart';


class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      emit(ForgotPasswordError("Please enter an email"));
      return;
    }
    emit(ForgotPasswordLoading());
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      emit(ForgotPasswordSuccess("Password reset email sent! Check your inbox."));
    } catch (e) {
      emit(ForgotPasswordError("Error: ${e.toString()}"));
    }
  }
}