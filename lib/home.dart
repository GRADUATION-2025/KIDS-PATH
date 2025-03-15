import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Function to handle sign-out
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user
      // Optionally, you can navigate to the login screen or show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );
    } catch (e) {
      // Handle errors (e.g., show an error message)
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
          onPressed: _signOut, // Call the sign-out function
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}