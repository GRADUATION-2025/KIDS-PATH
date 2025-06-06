import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../LOGIC/SIGNUP/cubit.dart';
import '../../LOGIC/SIGNUP/state.dart';

import '../../THEME/theme_provider.dart';
import 'Email Verify/Email Verify.dart';
import 'LOGIN_SCREEN.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return BlocProvider(
      create: (context) => SignupCubit(FirebaseAuth.instance),
      child: BlocConsumer<SignupCubit, SignUpStates>(
        listener: (context, state) {
          if (state is SignupSuccessState) {
            // Navigate to RoleSelectionScreen with the User object
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmailVerificationPage(),
              ),
            );
          } else if (state is SignUpErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          final isDark = themeProvider.isDarkMode;
          return Scaffold(

            body: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.r),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 12.h),
                              Text(
                                "Kids Path",
                                style: TextStyle(
                                  fontSize: 60.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 30.h),
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    // Email TextField with Icon
                                    TextFormField(
                                      controller: emailController,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: "Email",
                                          hintStyle: TextStyle(color: isDark?Colors.black:Colors.black),

                                        // labelText: "Email",
                                        // labelStyle: const TextStyle(color: Colors.black),
                                        prefixIcon: Icon(Icons.email, color: Color(0xFF08203E)), // Email Icon
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    // Password TextField with Icon
                                    TextFormField(
                                      controller: passwordController,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: "Password",
                                        hintStyle: TextStyle(color: isDark?Colors.black:Colors.black),
                                        // labelText: "Password",
                                        // labelStyle: const TextStyle(color: Colors.black),
                                        prefixIcon: Icon(Icons.lock, color: Color(0xFF08203E)), // Password Icon
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      obscureText: true,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                              InkWell(
                                onTap: () {
                                  if (formKey.currentState?.validate() ?? false) {
                                    final email = emailController.text;
                                    final password = passwordController.text;
                                    context.read<SignupCubit>().signup(email, password);
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Center(
                                    child: state is SignUpLoadingState
                                        ? CircularProgressIndicator(color: Colors.blueAccent)
                                        : Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Have an Account?", style: TextStyle(color: Colors.white)),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),



          );
        },
      ),
    );
  }
}