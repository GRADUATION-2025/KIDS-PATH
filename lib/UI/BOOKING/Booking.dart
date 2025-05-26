import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../LOGIC/booking/cubit.dart';
import '../../LOGIC/booking/state.dart';
import '../../DATA MODELS/Child Model/Child Model.dart';
import '../../LOGIC/child/child_cubit.dart';
import '../../LOGIC/child/child_state.dart';
import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';

class BookingScreen extends StatefulWidget {
  final String nurseryId;
  final String nurseryName;

  const BookingScreen({
    super.key,
    required this.nurseryId,
    required this.nurseryName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
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
    if (!_isValidDate(_selectedDate)) {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
      _focusedDate = _selectedDate;
    }
  }

  bool _isValidTime(TimeOfDay time) {
    // Nursery operating hours: 8 AM to 4 PM
    return time.hour >= 8 && time.hour <= 16;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              hourMinuteTextColor: Theme.of(context).textTheme.bodyLarge?.color,
              dayPeriodTextColor: Theme.of(context).textTheme.bodyLarge?.color,
              dialHandColor: Theme.of(context).colorScheme.primary,
              dialBackgroundColor: Theme.of(context).cardColor,
              dialTextColor: Theme.of(context).textTheme.bodyLarge?.color,
              entryModeIconColor: Theme.of(context).iconTheme.color,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (_isValidTime(picked)) {
        setState(() => _selectedTime = picked);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a time between 8 AM and 4 PM')),
          );
        }
      }
    }
  }

  bool _isValidDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    
    // Check if it's a weekend
    bool isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    
    return !isWeekend && (selectedDate.isAfter(today) || selectedDate.isAtSameMomentAs(today));
  }

  String _getFormattedTimeRange(TimeOfDay start) {
    final end = TimeOfDay(
      hour: (start.hour + 4) % 24,
      minute: start.minute,
    );
    return '${start.format(context)} - ${end.format(context)}';
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
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return AppGradients.Projectgradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      'Book Interview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.nurseryName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<BookingCubit, BookingState>(
            listener: (context, state) {
              if (state is BookingCreated) {
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking request sent!')),
                  );
                }
              } else if (state is BookingError) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              }
            },
          ),
        ],
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TableCalendar(
                      focusedDay: _focusedDate,
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 30)),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                      enabledDayPredicate: (day) => _isValidDate(day),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (_isValidDate(selectedDay)) {
                          setState(() {
                            _selectedDate = selectedDay;
                            _focusedDate = focusedDay;
                          });
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cannot select weekends or past dates'),
                              ),
                            );
                          }
                        }
                      },
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: Theme.of(context).textTheme.bodyMedium!,
                        weekendTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                        outsideTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                        disabledTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).disabledColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: TextStyle(color: Colors.white),
                        todayTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        weekendStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Select Time',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interview Duration: 4 hours',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          InkWell(
                            onTap: () => _selectTime(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getFormattedTimeRange(_selectedTime),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Icon(
                                  Icons.access_time,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Select Child',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    BlocBuilder<ChildCubit, ChildState>(
                      builder: (context, state) {
                        if (state is  ChildLoaded) {
                          return Column(
                            children: state.children.map((child) {
                              final isSelected = _selectedChild?.id == child.id;
                              return Container(
                                margin: EdgeInsets.only(bottom: 10.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () => setState(() => _selectedChild = child),
                                  title: Text(
                                    child.name,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${child.age} years old - ${child.gender}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).colorScheme.primary,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          );
                        } else if (state is ChildError) {
                          return Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
                  final isLoading = state is BookingLoading;
                  return Container(
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      gradient: isLoading ? null : AppGradients.Projectgradient,
                      color: isLoading ? Theme.of(context).disabledColor : null,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isLoading
                            ? null
                            : () {
                                if (_selectedChild == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select a child')),
                                  );
                                  return;
                                }

                                if (!_isValidDate(_selectedDate)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select a valid date')),
                                  );
                                  return;
                                }

                                if (!_isValidTime(_selectedTime)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select a time between 8 AM and 4 PM')),
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
                        borderRadius: BorderRadius.circular(12.r),
                        child: Center(
                          child: isLoading
                              ? SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Done',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
