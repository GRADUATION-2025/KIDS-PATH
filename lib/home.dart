import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'UI/WELCOME SCREENS/LOGIN_SCREEN.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Function to handle sign-out
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Show success message before navigating
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );

      // Wait a bit before navigating to ensure the snackbar is seen
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Success'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _signOut,
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}