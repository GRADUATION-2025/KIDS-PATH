
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

                if (!userData.exists) {
                  //  New user with no document yet
                  return RoleSelectionScreen(user: user);
                }

                final role = userData['role'];

                if (role == 'Parent') {
                  return BottombarParentScreen();
                } else if (role == 'Nursery') {
                  return BottombarNurseryScreen();
                } else {
                  return RoleSelectionScreen(user: user);
                }
              }
              // Safety fallback
              return RoleSelectionScreen(user: user);
            },
          );
        }
        return LoginScreen();
      },
    );
  }
}