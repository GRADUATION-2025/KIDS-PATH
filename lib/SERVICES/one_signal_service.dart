import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OneSignalService {
  static const String _appId = '6445d2e4-c795-47ef-8810-80ee242dc83c';
  static final OneSignalService _instance = OneSignalService._internal();

  factory OneSignalService() => _instance;

  OneSignalService._internal();

  Future<void> initialize() async {
    try {
      // Initialize OneSignal
      OneSignal.initialize(_appId);

      // Request notification permission
      OneSignal.Notifications.requestPermission(true);

      // Listen for subscription changes
      OneSignal.User.pushSubscription.addObserver((state) {
        debugPrint('Push subscription state changed: ${state.toString()}');
        final pushToken = OneSignal.User.pushSubscription.id;
        if (pushToken != null) {
          _storePlayerId(pushToken);
        }
      });

      // Set up foreground notification handler
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint('Foreground notification received: ${event.notification.title}');
        debugPrint('Notification data: ${event.notification.additionalData}');

        // Check if the notification is for the current user
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final notificationUserId = event.notification.additionalData?['userId'];
          if (notificationUserId != null && notificationUserId != currentUser.uid) {
            // Prevent notification from showing if it's not for the current user
            event.preventDefault();
            debugPrint('Prevented notification for different user');
            return;
          }
        }
      });

      // Set up notification opened handler
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('Notification clicked with data: ${event.notification.additionalData}');
        // Handle notification click here
      });

      // Check if notifications are enabled and store player ID
      final pushToken = OneSignal.User.pushSubscription.id;
      debugPrint('Notifications enabled: ${OneSignal.User.pushSubscription.optedIn}');
      if (pushToken != null) {
        await _storePlayerId(pushToken);
      }

      // Set external user ID if user is logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await setExternalUserId(currentUser.uid);
      }
    } catch (e) {
      debugPrint('Error initializing OneSignal: $e');
      rethrow;
    }
  }

  Future<void> _storePlayerId(String playerId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'oneSignalPlayerId': playerId,
          'lastUpdated': FieldValue.serverTimestamp()
        });
        debugPrint('OneSignal player ID stored in Firestore for user: ${user.uid}');
      }
    } catch (e) {
      debugPrint('Error storing player ID: $e');
    }
  }

  Future<void> setExternalUserId(String? userId) async {
    try {
      if (userId != null) {
        // First logout to clear any existing user
        await OneSignal.logout();

        // Wait a bit to ensure logout is complete
        await Future.delayed(const Duration(milliseconds: 2000));

        // Then login with the new user ID
        await OneSignal.login(userId);
        debugPrint('OneSignal external user ID set: $userId');

        // Get and store the player ID
        final pushToken = OneSignal.User.pushSubscription.id;
        if (pushToken != null) {
          await _storePlayerId(pushToken);
        }
      } else {
        await OneSignal.logout();
        debugPrint('OneSignal external user ID cleared');
      }
    } catch (e) {
      debugPrint('Error setting OneSignal external user ID: $e');
      rethrow;
    }
  }

  Future<void> setUserRole(String role) async {
    try {
      await OneSignal.User.addTags({'role': role});
      debugPrint('OneSignal user role set: $role');

      // Verify the tag was set
      final tags = await OneSignal.User.getTags();
      debugPrint('Current tags: $tags');
    } catch (e) {
      debugPrint('Error setting OneSignal user role: $e');
      rethrow;
    }
  }

  Future<void> sendTestNotification({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Create notification content
      final notificationContent = {
        'contents': {'en': message},
        'headings': {'en': title},
        'data': data ?? {},
      };

      // Send notification using the REST API
      final tags = {
        'last_notification_title': title,
        'last_notification_message': message,
      };

      await OneSignal.User.addTags(tags);
      debugPrint('Test notification sent successfully');
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      rethrow;
    }
  }

  // Method to get the device push token
  String? getDevicePushToken() {
    try {
      final pushToken = OneSignal.User.pushSubscription.id;
      debugPrint('Push token: $pushToken');
      debugPrint('Notifications enabled: ${OneSignal.User.pushSubscription.optedIn}');
      return pushToken;
    } catch (e) {
      debugPrint('Error getting device push token: $e');
      return null;
    }
  }

  // Method to check if notifications are enabled
  bool areNotificationsEnabled() {
    try {
      debugPrint('Notifications enabled: ${OneSignal.User.pushSubscription.optedIn}');
      debugPrint('Push token: ${OneSignal.User.pushSubscription.id}');
      return OneSignal.User.pushSubscription.optedIn ?? false;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }

  // Method to retry requesting notification permission
  Future<bool> retryNotificationPermission() async {
    try {
      final permission = await OneSignal.Notifications.requestPermission(true);
      debugPrint('Notification permission status: $permission');
      return permission;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
    }
}
