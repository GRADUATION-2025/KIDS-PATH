import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../UI/WELCOME SCREENS/LOGIN_SCREEN.dart';

class AccountActionsHandler {
  static Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  static Future<void> deleteAccount(BuildContext context, String userId, String userType) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        throw Exception('No user logged in');
      }

      // Delete from Firestore collections
      await Future.wait([
        firestore.collection('users').doc(userId).delete(),
        userType == 'Parent'
            ? firestore.collection('parents').doc(userId).delete()
            : firestore.collection('nurseries').doc(userId).delete(),
      ]);

      // Delete authentication account
      await user.delete();

      // Force sign out and redirect to login
      await signOut(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $e')),
      );
    }
  }

  static void showDeleteDialog(BuildContext context, String userId, String userType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to permanently delete your account? This cannot be undone."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await deleteAccount(context, userId, userType);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,);

                 // Close dialog


              },
            ),
          ],
        );
      },
    );
  }
}