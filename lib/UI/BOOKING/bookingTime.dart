import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../DATA MODELS/bookingModel/bookingModel.dart';
import '../../LOGIC/booking/cubit.dart';
import '../../LOGIC/booking/state.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return AppGradients.Projectgradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  );
                },
                child: const Text(
                  'Interview Times',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 2,
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
          child: Text('No Bookings Found',
              style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold
              )
          )
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingCubit>().initBookingsStream(
            isNursery: widget.isNursery);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.12),
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
              width: 55,
              height: 55,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 1.5, color: const Color(0xFF0D6EFD)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: profileImage != null
                    ? Image.network(profileImage, fit: BoxFit.cover)
                    : Container(
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0] : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!widget.isNursery)
            Text(
            'Child: ${booking.childName}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, MMMM dd').format(booking.dateTime),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          Text(
            '${DateFormat('h:mm a').format(booking.dateTime)} - ${DateFormat('h:mm a').format(booking.dateTime.add(const Duration(hours: 4)))}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (widget.isNursery)
    _NurseryActions(booking: booking)
    else
    _ParentActions(booking: booking),
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

  static Widget _buildStatusPill(String status) {
    final statusColors = {
      'confirmed': const Color(0xFF0D6EFD),
      'cancelled': Colors.grey,
      'pending': Colors.orange,
      'payment_pending': Colors.purple,
      'rated': Colors.green,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColors[status]!.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == 'rated' ? 'Rated' : status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: statusColors[status],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _NurseryActions extends StatelessWidget {
  final Booking booking;

  const _NurseryActions({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showChildDetails(context, booking),
        ),
        if (booking.status == 'pending') ...[
          _GradientActionButton(
            label: 'Approve',
            icon: Icons.check_circle_outline,
            gradientColors: AppGradients.Projectgradient.colors,
            onTap: () => context.read<BookingCubit>().updateBookingStatus(
                booking.id, 'payment_pending'),
          ),
          const SizedBox(height: 6),
          _GradientActionButton(
            label: 'Decline',
            icon: Icons.highlight_off_outlined,
            gradientColors: [const Color(0xFFEB4D5B), const Color(0xFFAE2B29)],
            onTap: () => context.read<BookingCubit>().updateBookingStatus(
                booking.id, 'cancelled'),
          ),
        ] else
          _buildStatusPill(booking.status),
      ],
    );
  }
}

class _ParentActions extends StatelessWidget {
  final Booking booking;

  const _ParentActions({required this.booking});

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
            onTap: () => _showRatingDialog(context, booking),
          ),
        if (booking.status != 'payment_pending' &&
            !(booking.status == 'confirmed' && !booking.rated))
          _buildStatusPill(booking.status),
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
void _showRatingDialog(BuildContext context, Booking booking) {
  showDialog(
    context: context,
    builder: (context) => RatingDialog(nurseryId: booking.nurseryId, bookingId: booking.id,),
  );
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
    return AlertDialog(
      title: const Text('Rate Nursery'),
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
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
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
void _showChildDetails(BuildContext context, Booking booking) {
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

Widget _buildStatusPill(String status) {
  final statusColors = {
    'confirmed': const Color(0xFF0D6EFD),
    'cancelled': Colors.grey,
    'pending': Colors.orange,
    'payment_pending': Colors.purple,
  };

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: statusColors[status]!.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status[0].toUpperCase() + status.substring(1),
      style: TextStyle(
        color: statusColors[status],
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );
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
        width: 100,
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
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
        width: 123,
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
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}