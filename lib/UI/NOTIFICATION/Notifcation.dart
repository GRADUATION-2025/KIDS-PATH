import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../DATA MODELS/Notification/Notification.dart';
import '../../LOGIC/notification/notification_cubit.dart';
import '../../LOGIC/notification/notification_state.dart';
import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart'; // make sure the path is correct

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.grey,
          elevation: 0,
          title: _GradientTitle('Notifications'),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(child: Text('No notifications yet'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.notifications.length,
                itemBuilder: (_, i) {
                  final note = state.notifications[i];
                  return Dismissible(
                    key: ValueKey(note.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: _buildTile(note),
                  );
                },
              );
            }
            if (state is NotificationError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTile(NotificationModel note) {
    final bool isPayment = note.type == 'payment';

    // status logic unchanged
    String statusText;
    Color statusColor;
    if (isPayment) {
      final title = note.title.toLowerCase();
      final success = title.contains('successful') || title.contains('received');
      statusText = success ? 'Done' : 'Failed';
      statusColor = success ? Colors.green : Colors.red;
    } else {
      if (note.title.contains('Confirmed')) {
        statusText = 'Confirmed';
        statusColor = Colors.green;
      } else if (note.title.contains('Accepted')) {
        statusText = 'Accepted';
        statusColor = Colors.green;
      } else if (note.title.contains('Rejected')) {
        statusText = 'Rejected';
        statusColor = Colors.red;
      } else {
        statusText = 'Pending';
        statusColor = Colors.grey;
      }
    }

    return ListTile(
      leading: Container(
        width:  40,
        height:  40,
        decoration: BoxDecoration(
          gradient: AppGradients.Projectgradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(isPayment ? Icons.payment : Icons.event_note, color: Colors.white),
      ),
      title: Text(note.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(note.message),
          const SizedBox(height: 4),
          Text('Booking ID: ${note.bookingId}'),
        ],
      ),
      trailing: Text(
        statusText,
        style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
      ),
    );
  }
}

/// Renders gradient-colored text using your Projectgradient.
class _GradientTitle extends StatelessWidget {
  final String text;
  const _GradientTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          AppGradients.Projectgradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white, // this will be masked by the shader
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
