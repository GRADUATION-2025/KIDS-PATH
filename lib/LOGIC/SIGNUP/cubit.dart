
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupCubit extends Cubit<SignUpStates> {
  final FirebaseAuth _auth;

  SignupCubit(this._auth) : super(SignUpInitial());

  Future<void> signup(String email, String password) async {
    emit(SignUpLoadingState());
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data in Firestore (without role)
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'role': '', // Role is initially empty
      }, SetOptions(merge: true));

      // Navigate to Role Selection Screen
      emit(SignupSuccessState(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      emit(SignUpErrorState(e.message ?? "Sign-up failed"));
    }
  }
}