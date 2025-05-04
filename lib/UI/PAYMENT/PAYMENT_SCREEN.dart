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

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  WebViewController? _controller;

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
              onNavigationRequest: (request) {
                if (request.url.contains('/success') || request.url.contains('success=true')) {
                  _handlePaymentSuccess();
                  return NavigationDecision.prevent;
                }

                if (request.url.contains('/fail') || request.url.contains('failed=true')) {
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
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Error'),
          content: Text('Failed to initialize payment: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _handlePaymentSuccess() async {


    final parentId = FirebaseAuth.instance.currentUser?.uid;
    final parentDoc = await FirebaseFirestore.instance.collection('parents').doc(parentId).get();
    final bookingDoc = await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).get();
    final parentName = parentDoc['name'];
    final childName = bookingDoc['childName'];
    final nurseryName = bookingDoc['nurseryName'];
    final nurseryId = bookingDoc['nurseryId'];
    final childId = bookingDoc['childId'];

    try {

      await context.read<BookingCubit>().updateBookingStatus(
          widget.bookingId,
          'confirmed'
      );

      // Assuming Paymob provides the last 4 digits in the payment response.
      final cardLast4 = "4245"; // Replace this with the actual last 4 digits from Paymob response

      // 🔹 Save payment info to Firestore, including cardLast4
      await FirebaseFirestore.instance.collection('Transaction-Data').add({
        'parentId': parentId,
        'name': parentName,
        'bookingId': widget.bookingId,
        'childName': childName,
        'nurseryName': nurseryName,
        'nurseryId': nurseryId,
        'childId':childId,
        'Amount': widget.amount,
        'Status': 'paid',
        'CreatedAt': FieldValue.serverTimestamp(),
        'CardLast4': cardLast4,
      });

      // 🔹 Update booking status to confirmed


      // 🔹 Refresh bookings and show success
      context.read<BookingCubit>().initBookingsStream(isNursery: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Booking confirmed'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Close loading or previous screen if needed

    } catch (e) {
      Navigator.pop(context); // Close any open dialogs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
