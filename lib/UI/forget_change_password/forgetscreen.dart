import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../LOGIC/forget password/cubit.dart';
import '../../LOGIC/forget password/state.dart';
import '../WELCOME SCREENS/LOGIN_SCREEN.dart'; // Import the login screen

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen())),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );

              // Navigate back to the login screen after a short delay
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              });
            } else if (state is ForgotPasswordError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Text(
                  "Enter your email and we will send you instructions on how to reset it",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 30),
                Text("Email", style: TextStyle(color: Colors.grey)),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                state is ForgotPasswordLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final email = emailController.text.trim();
                      context.read<ForgotPasswordCubit>().resetPassword(email);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text("Send", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}