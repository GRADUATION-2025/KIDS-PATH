import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../LOGIC/booking/cubit.dart';
import '../../LOGIC/booking/state.dart';
import '../../DATA MODELS/Child Model/Child Model.dart';
import '../../LOGIC/child/child_cubit.dart';
import '../../LOGIC/child/child_state.dart';

class BookingScreen extends StatefulWidget {
  final String nurseryId;
  final String nurseryName;

  const BookingScreen({
    super.key,
    required this.nurseryId,
    required this.nurseryName,
  });

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Child? _selectedChild;
  late String parentId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    parentId = user?.uid ?? '';
    if (parentId.isNotEmpty) {
      context.read<ChildCubit>().fetchChildren(parentId);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.nurseryName}'),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BookingCubit, BookingState>(
            listener: (context, state) {
              if (state is BookingCreated) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking request sent!')),
                );
              }
              if (state is BookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BlocBuilder<ChildCubit, ChildState>(
                builder: (context, state) {
                  if (state is ChildLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Child',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<Child>(
                          value: _selectedChild,
                          items: state.children.map((child) {
                            return DropdownMenuItem<Child>(
                              value: child,
                              child: Text(child.name),
                            );
                          }).toList(),
                          onChanged: (Child? newValue) {
                            setState(() {
                              _selectedChild = newValue;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Choose a child',
                          ),
                        ),
                      ],
                    );
                  } else if (state is ChildError) {
                    return Text(state.message);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 30),

              // Date & Time picker
              Text(
                'Select Date & Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat.yMMMMd().format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(context),
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Confirm Booking button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedChild == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a child')),
                      );
                      return;
                    }
                    final dateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );
                    context.read<BookingCubit>().createBooking(
                      dateTime: dateTime,
                      nurseryId: widget.nurseryId,
                      nurseryName: widget.nurseryName,
                      child: _selectedChild!,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
