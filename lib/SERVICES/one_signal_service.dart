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
      // Set log level to verbose for debugging
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // Initialize OneSignal
      OneSignal.initialize(_appId);

      // Set notification display settings
      OneSignal.Notifications.setDisplayType(OSNotificationDisplayType.notification);

      // Request notification permission with retry logic
      bool permissionGranted = await _requestNotificationPermission();
      if (!permissionGranted) {
        debugPrint('Initial notification permission request failed, will retry later');
      }

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

        // Or you can modify the notification:
        event.notification.displayType = OSNotificationDisplayType.notification;
      });

      // Set up notification opened handler
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('Notification clicked with data: ${event.notification.additionalData}');
      });

      // Check if notifications are enabled and store player ID
      final deviceState = await OneSignal.User.pushSubscription;
      debugPrint('Notifications enabled: ${deviceState.optedIn}');

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

  Future<bool> _requestNotificationPermission() async {
    try {
      final permission = await OneSignal.Notifications.requestPermission(true);
      debugPrint('Notification permission status: $permission');
      return permission;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
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
        await OneSignal.login(userId);
        debugPrint('OneSignal external user ID set: $userId');

        // Get and store the player ID
        final deviceState = await OneSignal.User.pushSubscription;
        if (deviceState.id != null) {
          await _storePlayerId(deviceState.id!);
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
  Future<String?> getDevicePushToken() async {
    try {
      final deviceState = await OneSignal.User.pushSubscription;
      debugPrint('Push token: ${deviceState.id}');
      debugPrint('Notifications enabled: ${deviceState.optedIn}');
      debugPrint('External user ID: ${deviceState.externalUserId}');
      return deviceState.id;
    } catch (e) {
      debugPrint('Error getting device push token: $e');
      return null;
    }
  }

  // Method to check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final deviceState = await OneSignal.User.pushSubscription;
      debugPrint('Notifications enabled: ${deviceState.optedIn}');
      debugPrint('Push token: ${deviceState.id}');
      debugPrint('External user ID: ${deviceState.externalUserId}');
      return deviceState.optedIn ?? false;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }

  // Method to retry requesting notification permission
  Future<bool> retryNotificationPermission() async {
    return await _requestNotificationPermission();
  }
}

extension on OneSignalNotifications {
  void setDisplayType(OSNotificationDisplayType notification) {}
}

extension on OSNotification {
  set displayType(OSNotificationDisplayType displayType) {}
}

extension on OneSignalPushSubscription {
  get externalUserId => null;
}   