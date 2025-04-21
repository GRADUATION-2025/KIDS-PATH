import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../UI/PROFILE SELECT SCREEN/User_Selection.dart';
import '../../WIDGETS/BOTTOM NAV BAR/BTM_BAR_NAV_NURSERY.dart';
import '../../WIDGETS/BOTTOM NAV BAR/BTM_BAR_NAV_PARENT.dart';
import 'state.dart';
import 'package:flutter/material.dart';

class LoginCubit extends Cubit<LoginStates> {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LoginCubit(this.firebaseAuth) : super(LogininitialState());

  Future<void> loginWithEmail(String email, String password, BuildContext context) async {
    emit(LoginLoadingState());
    try {
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _handleUserNavigation(userCredential.user, context);
    } catch (e) {
      emit(LoginErrorState(e.toString()));
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
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

      UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
      await _handleUserNavigation(userCredential.user, context);
    } catch (e) {
      emit(LoginErrorState("Google Sign-In Failed. Email Registered."));
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    emit(LoginLoadingState());
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
        await _handleUserNavigation(userCredential.user, context);
      } else {
        emit(LoginErrorState("Facebook Sign-In canceled."));
      }
    } catch (e) {
      emit(LoginErrorState("Facebook Sign-In Failed. Email Registered."));
    }
  }

  Future<void> _handleUserNavigation(User? user, BuildContext context) async {
    if (user == null) return;

    print("🔍 Checking Firestore for user role...");

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    if (userData != null && userData.containsKey('role') && userData['role'].isNotEmpty) {
      String role = userData['role'];

      print("📌 User Role Found: $role");

      if (role == 'Parent') {
        // Navigate to Parent profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottombarParentScreen()),
        );
      } else if (role == 'Nursery') {
        // Navigate to Nursery profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottombarNurseryScreen()),
        );
      }
    } else {
      print("🆕 New User - Redirecting to Role Selection");

      // Save user data in Firestore (if not already saved)
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'role': '', // Role is initially empty
      }, SetOptions(merge: true));

      // Navigate to Role Selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionScreen(user: user)),
      );
    }

    emit(LoginSucessState());
  }
}