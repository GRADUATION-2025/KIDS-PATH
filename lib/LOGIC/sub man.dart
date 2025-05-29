// subscription_manager.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionManager {
  static const String premiumStatus = 'premium';
  static const String basicStatus = 'basic';

  static Future<void> updateSubscriptionStatus({
    required String nurseryId,
    required String status,
  }) async {
    await FirebaseFirestore.instance
        .collection('nurseries')
        .doc(nurseryId)
        .update({'subscriptionStatus': status});
  }

  static Future<bool> isPremium(String nurseryId) async {
    final doc = await FirebaseFirestore.instance
        .collection('nurseries')
        .doc(nurseryId)
        .get();
    return doc['subscriptionStatus'] == premiumStatus;
  }

  static Future<void> cancelSubscription(String nurseryId) async {
    await updateSubscriptionStatus(
      nurseryId: nurseryId,
      status: basicStatus,
    );

    // Log cancellation
    await FirebaseFirestore.instance.collection('subscriptionCancellations').add({
      'nurseryId': nurseryId,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> canResubscribe(String nurseryId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('subscriptionCancellations')
        .where('nurseryId', isEqualTo: nurseryId)
        .orderBy('cancelledAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return true;

    final lastCancellation = snapshot.docs.first.data()['cancelledAt'] as Timestamp;
    final now = DateTime.now();
    final difference = now.difference(lastCancellation.toDate());

    // Allow resubscription after 24 hours
    return difference.inHours >= 24;
  }
}