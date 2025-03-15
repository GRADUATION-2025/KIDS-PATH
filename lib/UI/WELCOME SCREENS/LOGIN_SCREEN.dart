import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../LOGIC/LOGIN/cubit.dart';
import '../../LOGIC/LOGIN/state.dart';
import '../../home.dart';
import '../forget_change_password/forgetscreen.dart';
import 'REGISTER_SCREEN.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _keepMeSignedIn = false; // Checkbox state

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(FirebaseAuth.instance),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) {
          if (state is LoginSucessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login Successful")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          } else if (state is LoginErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0.r),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 12.h),
                        Text(
                          'Kids Path',
                          style: TextStyle(
                            fontSize: 60.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Pacifico',
                            letterSpacing: 2.sp,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              _buildTextField(emailController, "Email", Icons.email),
                              const SizedBox(height: 15),
                              _buildTextField(passwordController, "Password", Icons.lock, obscureText: true),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _keepMeSignedIn,
                                  onChanged: (value) {
                                    setState(() {
                                      _keepMeSignedIn = value!;
                                    });
                                  },
                                  activeColor: Colors.white, // Checkbox color
                                  checkColor: Colors.black, // Tick color
                                ),
                                const Text(
                                  'Keep me signed in',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text('Forgot password?', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        _buildButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              final email = emailController.text;
                              final password = passwordController.text;
                              context.read<LoginCubit>().loginWithEmail(email, password);
                            }
                          },
                          text: "Sign In",
                          isLoading: state is LoginLoadingState,
                        ),
                        const SizedBox(height: 15),
                        const Divider(color: Colors.white, thickness: 1),
                        const SizedBox(height: 15),
                        _buildSocialButton(
                          onPressed: () => context.read<LoginCubit>().signInWithGoogle(),
                          text: "Continue with Google",
                          imagePath: 'assets/IMAGES/download.png',
                          color: Colors.white,
                          textColor: Colors.black,
                        ),
                        SizedBox(height: 10.h),
                        _buildSocialButton(
                          onPressed: () => context.read<LoginCubit>().signInWithFacebook(),
                          text: "Continue with Facebook",
                          icon: Icons.facebook,
                          color: Colors.blue.shade800,
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't Have an Account?", style: TextStyle(color: Colors.white)),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool obscureText = false,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black), // Dark Gray Hint Text
        prefixIcon: Icon(icon, color: Color(0xFF08203E)), // Black Icons
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton({required VoidCallback onPressed, required String text, bool isLoading = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.blue)
          : Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String text,
    String? imagePath,
    IconData? icon,
    required Color color,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: imagePath != null
          ? Image.asset(imagePath, width: 24.w, height: 24.h)
          : Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(fontSize: 16, color: textColor)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../LOGIC/LOGIN/cubit.dart';
// import '../../LOGIC/LOGIN/state.dart';
// import '../../home.dart';
// import '../forget_change_password/forgetscreen.dart';
// import 'REGISTER_SCREEN.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => LoginCubit(FirebaseAuth.instance),
//       child: BlocConsumer<LoginCubit, LoginStates>(
//         listener: (context, state) {
//           if (state is LoginSucessState) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Login Successful")),
//             );
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const Home()),
//             );
//           } else if (state is LoginErrorState) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.errorMessage)),
//             );
//           }
//         },
//         builder: (context, state) {
//           return Scaffold(
//             body: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               child: Center(
//                 child: Padding(
//                   padding:  EdgeInsets.all(20.0.r),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(height: 12.h,),
//                          Text(
//                           'Kids Path',
//                           style: TextStyle(
//                             fontSize: 60.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             fontFamily: 'Pacifico',
//                             letterSpacing: 2.sp,
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                         Form(
//                           key: formKey,
//                           child: Column(
//                             children: [
//                               _buildTextField(emailController, "Email", Icons.email),
//                               const SizedBox(height: 15),
//                               _buildTextField(passwordController, "Password", Icons.lock, obscureText: true),
//                             ],
//                           ),
//                         ),
//                          SizedBox(height: 15.h),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Checkbox(value: false, onChanged: (value) {}),
//                                 const Text('Keep me signed in', style: TextStyle(color: Colors.white)),
//                               ],
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ForgotPasswordScreen()));
//                               },
//                               child: const Text('Forgot password?', style: TextStyle(color: Colors.white)),
//                             ),
//                           ],
//                         ),
//                          SizedBox(height: 20.h),
//                         _buildButton(
//                           onPressed: () {
//                             if (formKey.currentState?.validate() ?? false) {
//                               final email = emailController.text;
//                               final password = passwordController.text;
//                               context.read<LoginCubit>().loginWithEmail(email, password);
//                             }
//                           },
//                           text: "Sign In",
//                           isLoading: state is LoginLoadingState,
//                         ),
//                         const SizedBox(height: 15),
//                         const Divider(color: Colors.white, thickness: 1),
//                         const SizedBox(height: 15),
//                         _buildSocialButton(
//                           onPressed: () => context.read<LoginCubit>().signInWithGoogle(),
//                           text: "Continue with Google",
//                           imagePath: 'assets/IMAGES/download.png',
//                           color: Colors.white,
//                           textColor: Colors.black,
//                         ),
//                          SizedBox(height: 10.h),
//                         _buildSocialButton(
//                           onPressed: () => context.read<LoginCubit>().signInWithFacebook(),
//                           text: "Continue with Facebook",
//                           icon: Icons.facebook,
//                           color: Colors.blue.shade800,
//                         ),
//                          SizedBox(height: 20.h),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text("Don't Have an Account?", style: TextStyle(color: Colors.white)),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => const RegisterScreen()),
//                                 );
//                               },
//                               child: const Text(
//                                 'Sign Up',
//                                 style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildTextField(
//       TextEditingController controller,
//       String label,
//       IconData icon,
//       {bool obscureText = false}
//       ) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       style: const TextStyle(color: Colors.black),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black), // Dark Gray Hint Text
//         prefixIcon: Icon(icon, color: Color(0xFF08203E)), // Black Icons
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildButton({required VoidCallback onPressed, required String text, bool isLoading = false}) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       child: isLoading
//           ? const CircularProgressIndicator(color: Colors.blue)
//           : Text(text, style:  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
//     );
//   }
//
//   Widget _buildSocialButton({
//     required VoidCallback onPressed,
//     required String text,
//     String? imagePath,
//     IconData? icon,
//     required Color color,
//     Color textColor = Colors.white
//   }) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: imagePath != null
//           ? Image.asset(imagePath, width: 24.w, height: 24.h)
//           : Icon(icon, color: Colors.white),
//       label: Text(text, style: TextStyle(fontSize: 16, color: textColor)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: textColor,
//         minimumSize:  Size(double.infinity, 50.h),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       ),
//     );
//   }
// }
//