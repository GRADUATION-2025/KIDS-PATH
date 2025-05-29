// premium_features_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kidspath/DATA%20MODELS/Nursery%20model/Nursery%20Model.dart';
import 'package:kidspath/LOGIC/Nursery/nursery_cubit.dart';
import 'package:kidspath/LOGIC/Nursery/nursery_state.dart';

import 'package:kidspath/THEME/theme_provider.dart';
import 'package:kidspath/WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import 'package:kidspath/UI/PREMIUM/payment/PAYMENT_SCREEN.dart';

import '../../LOGIC/sub man.dart';

class PremiumFeaturesScreen extends StatefulWidget {
  final String nurseryId;

  const PremiumFeaturesScreen({
    Key? key,
    required this.nurseryId,
  }) : super(key: key);

  @override
  State<PremiumFeaturesScreen> createState() => _PremiumFeaturesScreenState();
}

class _PremiumFeaturesScreenState extends State<PremiumFeaturesScreen> {
  bool _isPremium = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    setState(() => _isLoading = true);
    _isPremium = await SubscriptionManager.isPremium(widget.nurseryId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text(
          'Premium Features',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              SizedBox(height: 24.h),
              _buildFeatureList(context, isDark),
              SizedBox(height: 32.h),
              _buildActionButton(context),
            ],
          ),
        ),
      ),
      floatingActionButton: _isPremium
          ? FloatingActionButton(
        onPressed: () => _showCancelDialog(context),
        child: const Icon(Icons.cancel),
        backgroundColor: Colors.red,
        tooltip: 'Cancel Subscription',
      )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppGradients.Projectgradient,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isPremium ? 'Premium Membership' : 'Upgrade to Premium',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _isPremium
                ? 'You have access to all premium features'
                : 'Get featured and grow your nursery',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context, bool isDark) {
    final features = [
      {
        'icon': Icons.star,
        'title': 'Featured Listing',
        'description': 'Get featured on the home screen to increase visibility',
        'premiumOnly': true,
      },

      {
        'icon': Icons.verified,
        'title': 'Premium Badge',
        'description': 'Display a premium badge to build trust with parents',
        'premiumOnly': true,
      },
      {
        'icon': Icons.priority_high,
        'title': 'Priority Support',
        'description': 'Get priority access to customer support',
        'premiumOnly': true,
      },
      {
        'icon': Icons.attach_money_sharp,
        'title': 'Upgrade to Premium',
        'description': 'Unlock all for just 400 EGP/month.',
        'premiumOnly': false,
      },
    ];

    return Column(
      children: features

          .map((feature) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: feature['premiumOnly'] as bool
                    ? const Color(0xFF07C8F9)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  feature['icon'] as IconData,
                  color: feature['premiumOnly'] as bool
                      ? const Color(0xFF07C8F9)
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  size: 24.sp,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        feature['description'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (feature['premiumOnly'] as bool)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20.sp,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return BlocConsumer<NurseryCubit, NurseryState>(
      listener: (context, state) {
        if (state is SubscriptionUpdateSuccess) {
          setState(() => _isPremium = state.newStatus == SubscriptionManager.premiumStatus);
        }
      },
      builder: (context, state) {
        if (state is SubscriptionUpdateLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            gradient: _isPremium
                ? AppGradients.Projectgradient
                : AppGradients.Projectgradient,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isPremium ? null : () => _handlePayment(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              disabledBackgroundColor: Colors.transparent,
            ),
            child: Text(
              _isPremium ? 'Current Premium Member' : 'Upgrade to Premium',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePayment(BuildContext context) async {
    try {
      final canResubscribe = await SubscriptionManager.canResubscribe(widget.nurseryId);
      if (!canResubscribe) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait 24 hours after cancellation to resubscribe'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Optional: Check if nursery doc exists (for other purposes)
      final nurseryDoc = await FirebaseFirestore.instance
          .collection('nurseries')
          .doc(widget.nurseryId)
          .get();

      if (nurseryDoc.exists) {
        double price = 400.0;  // Fixed price, ignoring Firestore price

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreenPremium(
              amount: price,
              nurseryId: widget.nurseryId,
            ),
          ),
        ).then((_) => _checkSubscriptionStatus());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Subscription'),
          content: const Text(
              'Are you sure you want to cancel your premium subscription?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _cancelSubscription(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelSubscription(BuildContext context) async {
    try {
      await SubscriptionManager.cancelSubscription(widget.nurseryId);

      // Refresh UI
      setState(() => _isPremium = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling subscription: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}