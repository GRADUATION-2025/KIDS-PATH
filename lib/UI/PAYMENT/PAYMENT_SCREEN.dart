import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../LOGIC/PAYMOB/paymob_helper.dart';
import '../../LOGIC/booking/cubit.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  final String nurseryId;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.nurseryId
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  WebViewController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      final orderId = await PaymobHelper.createOrder(widget.amount, widget.bookingId);
      final paymentKey = await PaymobHelper.getPaymentKey(
        orderId!,
        widget.amount,
        widget.bookingId,
      );

      if (paymentKey == null) throw Exception('Failed to get payment key');

      setState(() {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) async {
                if (request.url.contains('/success') ||
                    request.url.contains('success=true')) {
                  final uri = Uri.parse(request.url);
                  final paymentToken = uri.queryParameters['token'] ?? '';
                  if (!_isProcessing) {
                    _isProcessing = true;
                    await _handlePaymentSuccess(paymentToken);
                  }
                  return NavigationDecision.prevent;
                }

                if (request.url.contains('/fail') ||
                    request.url.contains('failed=true')) {
                  _handlePaymentFailure();
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(
            Uri.parse('https://accept.paymob.com/api/acceptance/iframes/911300?payment_token=$paymentKey'),
          );
      });
    } catch (e) {
      _showErrorDialog('Failed to initialize payment: ${e.toString()}');
    }
  }

  Future<void> _handlePaymentSuccess(String paymentToken) async {
    final parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      _showErrorDialog('User not authenticated');
      return;
    }

    try {
      // Get required documents
      final parentDoc = await FirebaseFirestore.instance
          .collection('parents').doc(parent.uid).get();
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings').doc(widget.bookingId).get();
      final nurseryDoc = await FirebaseFirestore.instance
          .collection('nurseries').doc(widget.nurseryId).get();

      // Validate documents
      if (!parentDoc.exists || !bookingDoc.exists || !nurseryDoc.exists) {
        _showErrorDialog('Missing required data');
        return;
      }

      // Extract data
      final parentData = parentDoc.data()!;
      final bookingData = bookingDoc.data()!;
      final nurseryData = nurseryDoc.data()!;

      // Update booking status
      await context.read<BookingCubit>().updateBookingStatus(
          widget.bookingId,
          'confirmed'
      );

      // Save to Transaction-Data collection
      await FirebaseFirestore.instance.collection('Transaction-Data').add({
        'parentId': parent.uid,
        'name': parentData['name'],
        'bookingId': widget.bookingId,
        'childName': bookingData['childName'],
        'nurseryName': bookingData['nurseryName'],
        'nurseryId': bookingData['nurseryId'],
        'childId': bookingData['childId'],
        'Amount': nurseryData['price'],
        'Status': 'paid',
        'CreatedAt': FieldValue.serverTimestamp(),
        'CardLast4': paymentToken.isNotEmpty ? paymentToken.substring(paymentToken.length - 4) : '****',
      });

      // Save to new payments collection
      await FirebaseFirestore.instance.collection('payments').add({
        'parentId': parent.uid,
        'cardToken': paymentToken,
        'bookingId': widget.bookingId,
        'paymentDate': FieldValue.serverTimestamp(),
        'amount': widget.amount,
        'nurseryId': widget.nurseryId,
      });

      // Refresh data and show success
      context.read<BookingCubit>().initBookingsStream(isNursery: false);
      _showSuccess('Payment successful! Booking confirmed');

    } catch (e) {
      _showErrorDialog('Payment processing failed: ${e.toString()}');
    } finally {
      _isProcessing = false;
    }
  }

  void _handlePaymentFailure() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment failed. Please try again'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showErrorDialog(String message) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Gateway')),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_controller == null)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}