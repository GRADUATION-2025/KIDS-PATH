import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../LOGIC/booking/cubit.dart';
import '../../LOGIC/booking/state.dart';
import '../../DATA MODELS/Child Model/Child Model.dart';
import '../../LOGIC/child/child_cubit.dart';
import '../../LOGIC/child/child_state.dart';
import '../../THEME/theme_provider.dart';
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
  }

  bool _isValidDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    // Check if it's a weekend
    bool isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    return !isWeekend && (selectedDate.isAfter(today) || selectedDate.isAtSameMomentAs(today));
  }


  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:  Size.fromHeight(50.h),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.Projectgradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Book ${widget.nurseryName}',
            style:  TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
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
              } else if (state is BookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
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
                      // Calendar
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
                        headerStyle:  HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold,
                              color: isDark?Colors.white:Colors.black),
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: TextStyle(color: isDark?Colors.white:Colors.black),
                          weekendTextStyle:TextStyle(color: isDark?Colors.white:Colors.black),
                        
                          outsideTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                          ),
                          disabledTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).disabledColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: const TextStyle(color: Colors.white),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(fontWeight: FontWeight.bold,
                              color: isDark?Colors.white:Colors.black),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Time Picker
                      Text('Select Time (Start only)', style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
                      color: isDark?Colors.white:Colors.black)),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text('Start',
                                 style: TextStyle(color: isDark?Colors.white:Colors.black),),
                                GestureDetector(
                                  onTap: () => _selectTime(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all( color: isDark?Colors.white:Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _selectedTime.format(context),
                                      style:  TextStyle(fontSize: 16.sp,color: isDark?Colors.white:Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text('End',
                              style: TextStyle(color: isDark?Colors.white:Colors.black),),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isDark?Colors.white:Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    TimeOfDay(
                                      hour: (_selectedTime.hour + 4) % 24,
                                      minute: _selectedTime.minute,
                                    ).format(context),
                                    style:  TextStyle(fontSize: 16.sp,color: isDark?Colors.white:Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // Child Selection
                      Text('Select Child', style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
                        color: isDark?Colors.white:Colors.black),),
                      SizedBox(height: 10.h),
                      BlocBuilder<ChildCubit, ChildState>(
                        builder: (context, state) {
                          if (state is ChildLoaded) {
                            return DropdownButtonFormField<Child>(
                              value: _selectedChild,
                              items: state.children.map((child) {
                                return DropdownMenuItem<Child>(
                                  value: child,
                                  child: Text(child.name),
                                );
                              }).toList(),
                              onChanged: (child) => setState(() => _selectedChild = child),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.blue.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.blue.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color:Colors.blue.shade300 ),
                                ),
                                labelText: 'Choose a Child',
                                labelStyle: TextStyle(color:isDark?Colors.black:Colors.blue),
                              ),
                              iconEnabledColor: Colors.blue,
                              dropdownColor: Colors.white,
                              style:  TextStyle(color: Colors.black, fontSize: 16.sp),
                            );
                          } else if (state is ChildError) {
                            return Text(state.message);
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                      SizedBox(height: 30.h),

                      BlocBuilder<BookingCubit, BookingState>(
                          builder: (context, state) {
                            final isLoading = state is BookingLoading;

                            return GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
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
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: isLoading
                                    ? BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(12),
                                )
                                    : AppGradients.buttonGradient,
                                alignment: Alignment.center,
                                child: isLoading
                                    ?  SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    :  Text(
                                  'Done',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                    ]),
              ),
            )],
        ),
      ),
    );
  }
}
