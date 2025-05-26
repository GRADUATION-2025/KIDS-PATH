import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kidspath/LOGIC/booking/cubit.dart';
import 'package:provider/provider.dart';
import 'THEME/app_theme.dart';
import 'THEME/theme_provider.dart';

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
  
  try {
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
          try {
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
          } catch (e) {
            debugPrint('Error getting user role: $e');
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
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // Show error UI or handle error appropriately
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) => MaterialApp(
            title: 'Kids Path',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: AuthWrapper(),
          ),
        );
      },
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
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Error: ${userSnapshot.error}"),
                        ElevatedButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text("Sign Out"),
                        ),
                      ],
                    ),
                  ),
                );
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
