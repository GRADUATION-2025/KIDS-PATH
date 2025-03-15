import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'state.dart';

class LoginCubit extends Cubit<LoginStates> {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  LoginCubit(this.firebaseAuth) : super(LoginSucessState());

  Future<void> loginWithEmail(String email, String password) async {
    emit(LoginLoadingState());
    try {
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      emit(LoginSucessState());
    } catch (e) {
      emit(LoginErrorState(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(LoginLoadingState());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(LoginErrorState("Google Sign-In canceled."));
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await firebaseAuth.signInWithCredential(credential);
      emit(LoginSucessState());
    } catch (e) {
      print("Google Sign-In Error: $e");
      emit(LoginErrorState("Google Sign-In Failed. Email Registered."));
    }
  }

  Future<void> signInWithFacebook() async {
    emit(LoginLoadingState());
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        await firebaseAuth.signInWithCredential(credential);
        emit(LoginSucessState());
      } else {
        emit(LoginErrorState("Facebook Sign-In canceled."));
      }
    } catch (e) {
      print("Facebook Sign-In Error: $e");
      emit(LoginErrorState("Facebook Sign-In Failed. Email Registered."));
    }
  }
}
