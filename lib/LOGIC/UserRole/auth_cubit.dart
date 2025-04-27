import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kidspath/WIDGETS/BOTTOM%20NAV%20BAR/BTM_BAR_NAV_PARENT.dart';
import '../../UI/PROFILE SELECT SCREEN/User_Selection.dart';
import '../../UI/WELCOME SCREENS/LOGIN_SCREEN.dart';
import '../../WIDGETS/BOTTOM NAV BAR/BTM_BAR_NAV_NURSERY.dart';
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          final User user = snapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userData = userSnapshot.data!;
                final userRole = userData['role'];

                if (userRole == 'Parent') {
                  return BottombarParentScreen(); // Navigate to Parent dashboard
                } else if (userRole == 'Nursery') {
                  return BottombarNurseryScreen(); // Navigate to Nursery dashboard
                } else {
                  return RoleSelectionScreen(user: user); // Navigate to role selection if role is not set
                }
              }
              return RoleSelectionScreen(user: user); // Navigate to role selection if no role is found
            },
          );
        }
        return LoginScreen(); // Redirect to login screen if not authenticated
      },
    );
  }
}