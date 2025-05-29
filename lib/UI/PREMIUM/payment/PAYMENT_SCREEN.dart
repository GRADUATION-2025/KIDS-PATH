// payment_screen_premium.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidspath/DATA%20MODELS/Nursery%20model/Nursery%20Model.dart';
import 'package:kidspath/LOGIC/Nursery/nursery_cubit.dart';
import 'package:kidspath/UI/Create_Profile_screen/NURSERY/NurseryProfileScreen.dart';
import 'package:kidspath/LOGIC/PAYMOB/premium%20paymob/paymob_helper.dart';
import '../../../LOGIC/PremiumUpgrade/sub man.dart';

class PaymentScreenPremium extends StatefulWidget {
  final String nurseryId;
  final double amount;

  const PaymentScreenPremium({
    super.key,
    required this.nurseryId,
    required this.amount,
  });

  @override
  State<PaymentScreenPremium> createState() => _PaymentScreenPremiumState();
}

class _PaymentScreenPremiumState extends State<PaymentScreenPremium> {
  WebViewController? _controller;
  bool _isProcessing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      setState(() => _isLoading = true);

      // Check if already premium
      final isPremium = await SubscriptionManager.isPremium(widget.nurseryId);
      if (isPremium) {
        _showErrorDialog('You already have an active premium subscription');
        return;
      }

      // Check if can resubscribe
      final canResubscribe = await SubscriptionManager.canResubscribe(widget.nurseryId);
      if (!canResubscribe) {
        _showErrorDialog('Please wait 24 hours after cancellation to resubscribe');
        return;
      }

      final orderId = await PaymobHelper.createOrder(widget.amount, widget.nurseryId);
      if (orderId == null) throw Exception('Failed to create order');

      final paymentKey = await PaymobHelper.getPaymentKey(
        orderId,
        widget.amount,
        widget.nurseryId,
      );
      if (paymentKey == null) throw Exception('Failed to get payment key');

      setState(() {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (req) async {
                final url = req.url;
                if ((url.contains('/success') || url.contains('success=true')) && !_isProcessing) {
                  _isProcessing = true;
                  await _handlePaymentSuccess();
                  return NavigationDecision.prevent;
                }
                if ((url.contains('/fail') || url.contains('failed=true')) && !_isProcessing) {
                  _isProcessing = true;
                  _handlePaymentFailure();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(
            'https://accept.paymob.com/api/acceptance/iframes/911300?payment_token=$paymentKey',
          ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Payment initialization failed: $e');
    }
  }

  Future<void> _handlePaymentSuccess() async {
    try {
      // Update subscription status
      await context.read<NurseryCubit>().updateSubscriptionStatus(
        nurseryId: widget.nurseryId,
        status: SubscriptionManager.premiumStatus,
      );

      // Log transaction
      await FirebaseFirestore.instance.collection('Premium-Upgrade').add({
        'nurseryId': widget.nurseryId,
        'amount': widget.amount,
        'status': 'paid',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send notification
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': currentUser.uid,
          'type': 'subscription',
          'title': 'Premium Activated',
          'message': 'Your premium subscription has been activated successfully',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }

      await _showSuccess('Payment successful! Premium activated.');
    } catch (e) {
      _showErrorDialog('Payment processing failed: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void _handlePaymentFailure() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': currentUser.uid,
        'type': 'subscription',
        'title': 'Payment Failed',
        'message': 'Premium subscription payment failed',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _isProcessing = false;
  }

  Future<void> _showSuccess(String msg) async {
    if (!mounted) return;

    // First pop the payment screen
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ));

        // Fetch nursery data and navigate to profile
        final nurseryDoc = await FirebaseFirestore.instance
            .collection('nurseries')
        .doc(widget.nurseryId)
        .get();

    final nursery = NurseryProfile.fromMap(nurseryDoc.data()!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => NurseryCubit(),
          child: NurseryProfileScreen(nursery: nursery),
        ),
      ),
    );
  }

  void _showErrorDialog(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Gateway'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isProcessing) return;
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null && !_isLoading)
            WebViewWidget(controller: _controller!),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}