// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../LOGIC/PAYMOB/paymob_helper.dart';
// import '../../LOGIC/booking/cubit.dart';
//
// class PaymentScreen extends StatefulWidget {
//   final String bookingId;
//   final double amount;
//   final String nurseryId;
//
//   const PaymentScreen({
//     super.key,
//     required this.bookingId,
//     required this.amount,
//     required this.nurseryId,
//   });
//
//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   WebViewController? _controller;
//   bool _isProcessing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePayment();
//   }
//
//   Future<void> _initializePayment() async {
//     try {
//       final orderId = await PaymobHelper.createOrder(widget.amount, widget.bookingId);
//       final paymentKey = await PaymobHelper.getPaymentKey(
//         orderId!,
//         widget.amount,
//         widget.bookingId,
//       );
//       if (paymentKey == null) throw Exception('Failed to get payment key');
//
//       setState(() {
//         _controller = WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..setNavigationDelegate(
//             NavigationDelegate(
//               onNavigationRequest: (req) async {
//                 final url = req.url;
//                 if ((url.contains('/success') || url.contains('success=true')) && !_isProcessing) {
//                   _isProcessing = true;
//                   await _handlePaymentSuccess();
//                   return NavigationDecision.prevent;
//                 }
//                 if ((url.contains('/fail') || url.contains('failed=true')) && !_isProcessing) {
//                   _isProcessing = true;
//                   _handlePaymentFailure();
//                   return NavigationDecision.prevent;
//                 }
//                 return NavigationDecision.navigate;
//               },
//             ),
//           )
//           ..loadRequest(Uri.parse(
//             'https://accept.paymob.com/api/acceptance/iframes/911300?payment_token=$paymentKey',
//           ));
//       });
//     } catch (e) {
//       _showErrorDialog('Initialization Error: $e');
//     }
//   }
//
//   Future<void> _handlePaymentSuccess() async {
//     final parent = FirebaseAuth.instance.currentUser;
//     if (parent == null) {
//       _showErrorDialog('User not authenticated');
//       return;
//     }
//
//     try {
//       // 1) Confirm booking
//       await context
//           .read<BookingCubit>()
//           .updateBookingStatus(widget.bookingId, 'confirmed');
//
//       // 2) Log transaction & fetch parent name
//       final parentDoc  = await FirebaseFirestore.instance
//           .collection('parents').doc(parent.uid).get();
//       final parentName = parentDoc['name'] as String;
//       final bookingDoc = await FirebaseFirestore.instance
//           .collection('bookings').doc(widget.bookingId).get();
//       final nurseryDoc = await FirebaseFirestore.instance
//           .collection('nurseries').doc(widget.nurseryId).get();
//
//       await FirebaseFirestore.instance.collection('Transaction-Data').add({
//         'parentId': parent.uid,
//         'name': parentName,
//         'bookingId': widget.bookingId,
//         'childName': bookingDoc['childName'],
//         'nurseryName': bookingDoc['nurseryName'],
//         'nurseryId': bookingDoc['nurseryId'],
//         'childId': bookingDoc['childId'],
//         'Amount': nurseryDoc['price'],
//         'Status': 'paid',
//         'CreatedAt': FieldValue.serverTimestamp(),
//       });
//
//       // 3a) Parent notification
//       await FirebaseFirestore.instance.collection('notifications').add({
//         'userId': parent.uid,
//         'type': 'payment',
//         'title': 'Payment Successful',
//         'message': 'Your payment for booking ${widget.bookingId} succeeded.',
//         'bookingId': widget.bookingId,
//         'timestamp': FieldValue.serverTimestamp(),
//         'isRead': false,
//       });
//
//       // 3b) Nursery notification with parent name
//       await FirebaseFirestore.instance.collection('notifications').add({
//         'userId': widget.nurseryId,
//         'type': 'payment',
//         'title': 'Payment Received',
//         'message':
//         'You’ve received payment from $parentName for booking ${widget.bookingId}.',
//         'bookingId': widget.bookingId,
//         'timestamp': FieldValue.serverTimestamp(),
//         'isRead': false,
//       });
//
//       _showSuccess('Payment successful! Booking confirmed.');
//     } catch (e) {
//       _showErrorDialog('Processing Error: $e');
//     } finally {
//       _isProcessing = false;
//     }
//   }
//
//   void _handlePaymentFailure() async {
//     final parent = FirebaseAuth.instance.currentUser;
//     if (parent != null) {
//       await FirebaseFirestore.instance.collection('notifications').add({
//         'userId': parent.uid,
//         'type': 'payment',
//         'title': 'Payment Failed',
//         'message': 'Your payment for booking ${widget.bookingId} failed.',
//         'bookingId': widget.bookingId,
//         'timestamp': FieldValue.serverTimestamp(),
//         'isRead': false,
//       });
//     }
//     Navigator.pop(context);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Payment failed. Please try again.'), backgroundColor: Colors.red),
//     );
//     _isProcessing = false;
//   }
//
//   void _showErrorDialog(String msg) {
//     if (!mounted) return;
//     Navigator.pop(context);
//     showDialog(context: context, builder: (_) => AlertDialog(
//       title: const Text('Error'),
//       content: Text(msg),
//       actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
//     ));
//   }
//
//   void _showSuccess(String msg) {
//     if (!mounted) return;
//     Navigator.pop(context);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.green),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payment Gateway')),
//       body: Stack(
//         children: [
//           if (_controller != null) WebViewWidget(controller: _controller!),
//           if (_controller == null) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }

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
    required this.nurseryId,
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
      });
    } catch (e) {
      _showErrorDialog('Initialization Error: $e');
    }
  }

  Future<void> _handlePaymentSuccess() async {
    final parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      _showErrorDialog('User not authenticated');
      return;
    }

    try {
      // 1) Confirm booking
      await context
          .read<BookingCubit>()
          .updateBookingStatus(widget.bookingId, 'confirmed');

      // 2) Fetch necessary data
      final parentDoc = await FirebaseFirestore.instance
          .collection('parents').doc(parent.uid).get();
      final parentName = parentDoc['name'] as String;
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings').doc(widget.bookingId).get();
      final nurseryDoc = await FirebaseFirestore.instance
          .collection('nurseries').doc(widget.nurseryId).get();
      final childName = bookingDoc['childName'] as String;

      // 3) Log transaction
      await FirebaseFirestore.instance.collection('Transaction-Data').add({
        'parentId': parent.uid,
        'name': parentName,
        'bookingId': widget.bookingId,
        'childName': childName,
        'nurseryName': bookingDoc['nurseryName'],
        'nurseryId': bookingDoc['nurseryId'],
        'childId': bookingDoc['childId'],
        'Amount': nurseryDoc['price'],
        'Status': 'paid',
        'CreatedAt': FieldValue.serverTimestamp(),
      });

      // 4a) Parent notification
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': parent.uid,
        'type': 'payment',
        'title': 'Payment Successful',
        'message': 'Your payment for $childName\'s booking succeeded.',
        'bookingId': widget.bookingId,
        'childName': childName,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // 4b) Nursery notification
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': widget.nurseryId,
        'type': 'payment',
        'title': 'Payment Received',
        'message': 'Payment received from $parentName for $childName\'s booking.',
        'bookingId': widget.bookingId,
        'childName': childName,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      _showSuccess('Payment successful! Booking confirmed.');
    } catch (e) {
      _showErrorDialog('Processing Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void _handlePaymentFailure() async {
    final parent = FirebaseAuth.instance.currentUser;
    if (parent != null) {
      try {
        final bookingDoc = await FirebaseFirestore.instance
            .collection('bookings').doc(widget.bookingId).get();
        final childName = bookingDoc['childName'] as String;

        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': parent.uid,
          'type': 'payment',
          'title': 'Payment Failed',
          'message': 'Payment failed for $childName\'s booking.',
          'bookingId': widget.bookingId,
          'childName': childName,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      } catch (e) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': parent.uid,
          'type': 'payment',
          'title': 'Payment Failed',
          'message': 'Payment processing failed.',
          'bookingId': widget.bookingId,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment failed. Please try again.'), backgroundColor: Colors.red),
    );
    _isProcessing = false;
  }

  void _showErrorDialog(String msg) {
    if (!mounted) return;
    Navigator.pop(context);
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Error'),
      content: Text(msg),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Gateway')),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_controller == null) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}