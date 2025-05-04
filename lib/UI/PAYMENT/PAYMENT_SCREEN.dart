import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  bool _isLoading = true;

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
                // Handle Paymob's success pattern
                if (request.url.contains('/success') ||
                    request.url.contains('success=true')) {
                  _handlePaymentSuccess();
                  return NavigationDecision.prevent;
                }

                // Add more specific checks if needed
                if (request.url.contains('/fail') ||
                    request.url.contains('failed=true')) {
                  _handlePaymentFailure();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            )
          )
          ..loadRequest(
            Uri.parse('https://accept.paymob.com/api/acceptance/iframes/911300?payment_token=$paymentKey'),
          );
      });
    } on Exception catch (e) {
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
    // Close webview first
    Navigator.pop(context);



    try {
      await context.read<BookingCubit>().updateBookingStatus(
          widget.bookingId,
          'confirmed'
      );

      // Close loading and refresh
      Navigator.pop(context); // Close loading
      context.read<BookingCubit>().initBookingsStream(isNursery: false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Booking confirmed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status update failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentFailure() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment failed. Please try again')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Gateway')),
      body:
      Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller!),

        ],
      ),
    );
  }
}