// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import 'LOGIC/LOGIN/cubit.dart';
// import 'LOGIC/forget password/cubit.dart';
// import 'UI/WELCOME SCREENS/LOGIN_SCREEN.dart';
// import 'firebase_options.dart'; // Ensure this file exists
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//     // Firebase config
//   );
//
//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => ForgotPasswordCubit()),
//
//       ],
//       child: const MyApp(), // Add "const" here if MyApp is immutable
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
//       designSize: const Size(360, 690), // Base size (adjust if needed)
//       minTextAdapt: true,
//       splitScreenMode: true,
//       child: MaterialApp(
//         title: 'Kids Path',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         home: const LoginScreen(),
//       ),
//     );
//   }
// }
//

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import 'LOGIC/LOGIN/cubit.dart';
// import 'LOGIC/forget password/cubit.dart';
// import 'UI/WELCOME SCREENS/LOGIN_SCREEN.dart';
// import 'firebase_options.dart';
// import 'home.dart'; // Ensure this file exists
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//     // Firebase config
//   );
//
//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => ForgotPasswordCubit()),
//       ],
//       child: const MyApp(), // Add "const" here if MyApp is immutable
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
//       designSize: const Size(360, 690), // Base size (adjust if needed)
//       minTextAdapt: true,
//       splitScreenMode: true,
//       child: MaterialApp(
//         title: 'Kids Path',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         home: AuthWrapper(), // Use AuthWrapper as the home screen
//       ),
//     );
//   }
// }
//
// class AuthWrapper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(body: Center(child: CircularProgressIndicator()));
//         }
//         if (snapshot.hasData && snapshot.data != null) {
//           return Home(); // Replace with your actual home screen widget
//         }
//         return LoginScreen(); // Replace with your actual sign-in screen widget
//       },
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'LOGIC/LOGIN/cubit.dart';
import 'LOGIC/forget password/cubit.dart';
import 'UI/WELCOME SCREENS/LOGIN_SCREEN.dart';
import 'firebase_options.dart';
import 'home.dart'; // Ensure this file exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    // Firebase config
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ForgotPasswordCubit()),
      ],
      child: const MyApp(), // Add "const" here if MyApp is immutable
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Base size (adjust if needed)
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'Kids Path',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: AuthWrapper(), // Use AuthWrapper as the home screen
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
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Home(); // Replace with your actual home screen widget
        }
        return LoginScreen(); // Replace with your actual sign-in screen widget
      },
    );
  }
}