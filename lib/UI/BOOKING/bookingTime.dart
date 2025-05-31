import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../DATA MODELS/bookingModel/bookingModel.dart';
import '../../LOGIC/booking/cubit.dart';
import '../../LOGIC/booking/state.dart';
import '../../THEME/theme_provider.dart';
import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import '../PAYMENT/PAYMENT_SCREEN.dart';

class BookingTimesScreen extends StatefulWidget {
  final bool isNursery;

  const BookingTimesScreen({required this.isNursery});

  @override
  State<BookingTimesScreen> createState() => _BookingTimesScreenState();
}

class _BookingTimesScreenState extends State<BookingTimesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingCubit>().initBookingsStream(
          isNursery: widget.isNursery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return AppGradients.Projectgradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  );
                },
                child: Text(
                  'Interview Times',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 2.h,
                width: MediaQuery.of(context).size.width / 2,
                decoration: const BoxDecoration(
                  gradient: AppGradients.Projectgradient,
                ),
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingsLoaded) {
            final sortedBookings = state.bookings.toList()
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
            return _buildBookingsList(context, sortedBookings);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'No Bookings Found',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingCubit>().initBookingsStream(
          isNursery: widget.isNursery,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          // Only make cancelled/confirmed bookings dismissible
          if (booking.status == 'cancelled' || booking.status == 'confirmed') {
            return Dismissible(
              key: Key(booking.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white, size: 36),
              ),
              confirmDismiss: (direction) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Booking'),
                    content: const Text('Are you sure you want to permanently delete this booking?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                context.read<BookingCubit>().deleteBooking(booking.id);
              },
              child: _buildBookingItem(context, booking),
            );
          }

          // For other statuses, show regular booking item
          return _buildBookingItem(context, booking);
        },
      ),
    );
  }

  Widget _buildBookingItem(BuildContext context, Booking booking) {
    final displayName = widget.isNursery ? booking.parentName : booking.nurseryName;
    final profileImage = widget.isNursery ? booking.parentProfileImage : booking.nurseryProfileImage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 55.w,
                height: 55.h,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(width: 1.5.w, color: const Color(0xFF0D6EFD)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: profileImage != null
                      ? CachedNetworkImage( fit: BoxFit.cover, imageUrl: profileImage)
                      : Container(
                    color: Theme.of(context).cardColor,
                    alignment: Alignment.center,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0] : '?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    if (!widget.isNursery)
                      Text(
                        'Child: ${booking.childName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
                      ),
                    SizedBox(height: 4.h),
                    Text(
                      DateFormat('EEEE, MMMM dd').format(booking.dateTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
                    ),
                    Text(
                      '${DateFormat('h:mm a').format(booking.dateTime)} - ${DateFormat('h:mm a').format(booking.dateTime.add(const Duration(hours: 4)))}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (widget.isNursery)
                _NurseryActions(
                  booking: booking,
                  onShowChildDetails: () => _showChildDetails(context, booking),
                  onBuildStatusPill: (status) => _buildStatusPill(context,status),
                )
              else
                _ParentActions(
                  booking: booking,
                  onShowRatingDialog: () => _showRatingDialog(context, booking),
                  onBuildStatusPill: (status) => _buildStatusPill(context,status),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showChildDetails(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Child Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${booking.childName}'),
            Text('Age: ${booking.childAge}'),
            Text('Gender: ${booking.childGender}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void _showRatingDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        nurseryId: booking.nurseryId,
        bookingId: booking.id,
      ),
    );
  }

  static Widget _buildStatusPill( BuildContext context,  String status) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final statusColors = {
      'confirmed': const Color(0xFF0D6EFD),
      'cancelled': Colors.grey,
      'pending': Colors.orange,
      'payment_pending': isDark ? Colors.yellow : Colors.deepPurple,
      'rated': Colors.green,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColors[status]!.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status == 'rated' ? 'Rated' : status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: statusColors[status],
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

class _NurseryActions extends StatelessWidget {
  final Booking booking;
  final VoidCallback onShowChildDetails;
  final Widget Function(String) onBuildStatusPill;

  const _NurseryActions({
    required this.booking,
    required this.onShowChildDetails,
    required this.onBuildStatusPill,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: onShowChildDetails,
        ),
        if (booking.status == 'pending') ...[
          _GradientActionButton(
            label: 'Approve',
            icon: Icons.check_circle_outline,
            gradientColors: AppGradients.Projectgradient.colors,
            onTap: () => context.read<BookingCubit>().updateBookingStatus(
                booking.id, 'payment_pending'),
          ),
          SizedBox(height: 6.h),
          _GradientActionButton(
            label: 'Decline',
            icon: Icons.highlight_off_outlined,
            gradientColors: [const Color(0xFFEB4D5B), const Color(0xFFAE2B29)],
            onTap: () => context.read<BookingCubit>().updateBookingStatus(
                booking.id, 'cancelled'),
          ),
        ] else
          onBuildStatusPill(booking.status),
      ],
    );
  }
}

class _ParentActions extends StatelessWidget {
  final Booking booking;
  final VoidCallback onShowRatingDialog;
  final Widget Function(String) onBuildStatusPill;

  const _ParentActions({
    required this.booking,
    required this.onShowRatingDialog,
    required this.onBuildStatusPill,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (booking.status == 'payment_pending')
          _GradientActionButton(
            label: 'Payment',
            icon: Icons.payment,
            gradientColors: AppGradients.Projectgradient.colors,
            onTap: () => _handlePayment(context, booking),
          ),
        if (booking.status == 'confirmed' && !booking.rated)
          _GradientRateButton(
            label: 'Rate Nursery',
            icon: Icons.star_outline,
            gradientColors: AppGradients.Projectgradient.colors,
            onTap: onShowRatingDialog,
          ),
        if (booking.status != 'payment_pending' &&
            !(booking.status == 'confirmed' && !booking.rated))
          onBuildStatusPill(booking.status),
      ],
    );
  }

  void _handlePayment(BuildContext context, Booking booking) async {
    try {
      final nurseryDoc = await FirebaseFirestore.instance
          .collection('nurseries')
          .doc(booking.nurseryId)
          .get();

      if (nurseryDoc.exists) {
        final priceData = nurseryDoc['price'];
        double price = 0.0;

        if (priceData is String) {
          price = double.tryParse(priceData) ?? 0.0;
        } else if (priceData is num) {
          price = priceData.toDouble();
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              bookingId: booking.id,
              amount: price,
              nurseryId: booking.nurseryId,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: ${e.toString()}')),
      );
    }
  }
}

class RatingDialog extends StatefulWidget {
  final String nurseryId;
  final String bookingId;

  const RatingDialog({
    required this.nurseryId,
    required this.bookingId,
  });

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: Text(
        'Rate Nursery',
        style: GoogleFonts.inter(fontSize: 30.sp,fontWeight: FontWeight.bold,
            color: isDark?Colors.white:Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 40,
              ),
              onPressed: () => setState(() => _rating = index + 1),
            )),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Comment (optional)',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _rating > 0 ? () {
            context.read<BookingCubit>().submitRating(
              nurseryId: widget.nurseryId,
              bookingId: widget.bookingId,
              rating: _rating,
              comment: _commentController.text,
            );
            Navigator.pop(context);
          } : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _GradientActionButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientRateButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _GradientRateButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130.w,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

