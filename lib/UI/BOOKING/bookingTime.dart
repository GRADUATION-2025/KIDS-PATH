// Updated BookingTimesScreen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../DATA MODELS/bookingModel/bookingModel.dart';
import '../../LOGIC/booking/cubit.dart';
import '../../LOGIC/booking/state.dart';

class BookingTimesScreen extends StatelessWidget {
  final bool isNursery;
  const BookingTimesScreen({required this.isNursery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is BookingStatusUpdated) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is BookingsLoaded) {
            return _buildBookingsList(context, state.bookings);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, List<Booking> bookings) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingItem(context, booking);
      },
    );
  }

  Widget _buildBookingItem(BuildContext context, Booking booking) {
    final displayName = isNursery ? booking.parentName : booking.nurseryName;
    final profileImage = isNursery ? booking.parentProfileImage : booking.nurseryProfileImage;
    final statusText = isNursery ? 'Parent' : 'Nursery';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundImage: profileImage != null
              ? NetworkImage(profileImage)
              : null,
          child: profileImage == null
              ? Text(displayName.isNotEmpty ? displayName[0] : '?')
              : null,
        ),
        title: Text(
          DateFormat('MMM dd, yyyy - hh:mm a').format(booking.dateTime),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '$statusText: $displayName\n'
              'Status: ${booking.status}\n'
              'Child: ${booking.childName} (${booking.childAge}, ${booking.childGender})',
        ),
        trailing: isNursery
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showChildDetails(context, booking),
            ),
            if (booking.status == 'pending') ...[
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => context.read<BookingCubit>()
                    .updateBookingStatus(booking.id, 'confirmed'),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => context.read<BookingCubit>()
                    .updateBookingStatus(booking.id, 'cancelled'),
              ),
            ],
          ],
        )
            : _buildStatusIndicator(booking.status),
      ),
    );
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

  Widget _buildStatusIndicator(String status) {
    final statusColors = {
      'confirmed': Colors.green,
      'cancelled': Colors.red,
      'pending': Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColors[status]!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: statusColors[status],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}