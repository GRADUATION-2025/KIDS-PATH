import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kidspath/LOGIC/booking/cubit.dart';

import 'LOGIC/Home/home_cubit.dart';
import 'LOGIC/Notification/notification_cubit.dart';
import 'LOGIC/Nursery/nursery_cubit.dart';
import 'LOGIC/chat/cubit.dart';
import 'LOGIC/child/child_cubit.dart';
import 'LOGIC/forget password/cubit.dart';
import 'LOGIC/Parent/parent_cubit.dart';
import 'SERVICES/one_signal_service.dart';
import 'UI/PROFILE SELECT SCREEN/User_Selection.dart';
import 'UI/Splash_Screen/splash_screen.dart';
import 'UI/WELCOME SCREENS/LOGIN_SCREEN.dart';
import 'WIDGETS/BOTTOM NAV BAR/BTM_BAR_NAV_NURSERY.dart';
import 'WIDGETS/BOTTOM NAV BAR/BTM_BAR_NAV_PARENT.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize OneSignal
  try {
    await OneSignalService().initialize();

    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // User is signed in
        await OneSignalService().setExternalUserId(user.uid);

        // Get user role and set it in OneSignal
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final role = userDoc.data()?['role'];
          if (role != null) {
            await OneSignalService().setUserRole(role);
          }
        }
      } else {
        // User is signed out
        await OneSignalService().setExternalUserId(null);
      }
    });
  } catch (e) {
    debugPrint('Error initializing OneSignal: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ForgotPasswordCubit()),
        BlocProvider(create: (context) => ParentCubit()),
        BlocProvider(create: (context) => NurseryCubit()),
        BlocProvider(create: (context) => HomeCubit()),
        BlocProvider(create: (context) => ChildCubit()),
        BlocProvider(create: (context) => ChatCubit()),
        BlocProvider(create: (context) => BookingCubit()),
        BlocProvider(create: (context) => NotificationCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'Kids Path',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (userSnapshot.hasError) {
                return const Scaffold(body: Center(child: Text("Something went wrong")));
              }

              // Check if user document exists
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

                // Check if 'role' field exists
                final role = userData?['role'];
                if (role == 'Parent') {
                  return const BottombarParentScreen();
                } else if (role == 'Nursery') {
                  return BlocProvider(
                    create: (context) => NurseryCubit()..fetchNurseryData(user.uid),
                    child: const BottombarNurseryScreen(),
                  );
                }
              }

              // Role not selected yet — send to Role Selection
              return RoleSelectionScreen(user: user);
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}

//
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kidspath/LOGIC/booking/cubit.dart';
// import 'package:kidspath/LOGIC/chat/cubit.dart';
// import 'package:kidspath/LOGIC/child/child_cubit.dart';
//  import 'package:kidspath/LOGIC/home/home_cubit.dart';
// import 'package:kidspath/LOGIC/notification/notification_cubit.dart'; // Ensure correct import
// import 'package:kidspath/LOGIC/nursery/nursery_cubit.dart';
// import 'package:kidspath/LOGIC/parent/parent_cubit.dart';
// import 'package:kidspath/UI/splash_screen/splash_screen.dart';
// import 'LOGIC/forget password/cubit.dart';
// import 'UI/PROFILE SELECT SCREEN/User_Selection.dart';
// import 'UI/WELCOME SCREENS/LOGIN_SCREEN.dart';
// import 'WIDGETS/BOTTOM NAV BAR/BTM_BAR_NAV_NURSERY.dart';
// import 'WIDGETS/BOTTOM NAV BAR/BTM_BAR_NAV_PARENT.dart';
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//
//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => ForgotPasswordCubit()),
//         BlocProvider(create: (context) => ParentCubit()),
//         BlocProvider(create: (context) => NurseryCubit()),
//         BlocProvider(create: (context) => HomeCubit()),
//         BlocProvider(create: (context) => ChildCubit()),
//         BlocProvider(create: (context) => ChatCubit()),
//         BlocProvider(create: (context) => BookingCubit()),
//         BlocProvider(
//           create: (context) => NotificationCubit()..fetchNotifications(),
//         ),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(360, 690),
//       child: MaterialApp(
//         title: 'Kids Path',
//         debugShowCheckedModeBanner: false,
//         home: SplashScreen(),
//       ),
//     );
//   }
// }
//
// // class AuthWrapper extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<User?>(
// //       stream: FirebaseAuth.instance.authStateChanges(),
// //       builder: (context, snapshot) {
// //         // ... rest of your AuthWrapper code
// //         // Ensure no nested BlocProviders override the root NotificationCubit
// //         return const BottombarParentScreen(); // Or NurseryScreen based on role
// //       },
// //     );
// //   }
// // }
//
//
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(body: Center(child: CircularProgressIndicator()));
//         }
//
//         if (snapshot.hasData && snapshot.data != null) {
//           final user = snapshot.data!;
//
//           return FutureBuilder<DocumentSnapshot>(
//             future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
//             builder: (context, userSnapshot) {
//               if (userSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Scaffold(body: Center(child: CircularProgressIndicator()));
//               }
//
//               if (userSnapshot.hasError) {
//                 return const Scaffold(body: Center(child: Text("Something went wrong")));
//               }
//
//               if (userSnapshot.hasData && userSnapshot.data!.exists) {
//                 final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
//
//                 final role = userData?['role'];
//                 if (role == 'Parent') {
//                   return const BottombarParentScreen();
//                 } else if (role == 'Nursery') {
//                   return BlocProvider(
//                     create: (context) => NurseryCubit()..fetchNurseryData(user.uid),
//                     child: const BottombarNurseryScreen(),
//                   );
//                 }
//               }
//
//               // If no role, go to role selection
//               return RoleSelectionScreen(user: user);
//             },
//           );
//         }
//
//         return const LoginScreen();
//       },
//     );
//   }
// }
