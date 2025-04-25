import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kidspath/UI/Create_Profile_screen/NURSERY/NURSERY_PAGE.dart';
import 'package:kidspath/WIDGETS/GRADIENT_COLOR/gradient%20_color.dart';
import '../../UI/BOOKING/Booking.dart';

import '../../UI/CHAT/chatList.dart';
import '../../UI/NOTIFICATION/Notifcation.dart';
import '../../UI/CHAT/chat.dart';

class BottombarNurseryScreen extends StatefulWidget {
  final int initialIndex;

  const BottombarNurseryScreen({super.key, this.initialIndex = 0}); // Default is Home

  @override
  State<BottombarNurseryScreen> createState() => _BottombarNurseryScreenState();
}

class _BottombarNurseryScreenState extends State<BottombarNurseryScreen> {
  late int _selectedindex;

  @override
  void initState() {
    super.initState();
    _selectedindex = widget.initialIndex; // Set starting tab
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedindex,
        children: [
          ChatListScreen(),
          Booking_screen(),
          Notifcation_Screen(),
          NurseryAccountScreen(),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedindex,
        onTap: (index) {
          setState(() {
            _selectedindex = index;
          });
        },
        showSelectedLabels: true, // Show selected labels
        showUnselectedLabels: false, // Show unselected labels
        selectedItemColor: Color(0xFF156CD7),
        selectedIconTheme: IconThemeData(color: Colors.red),
        unselectedItemColor: Color(0xFF515978),
        selectedLabelStyle: GoogleFonts.inter(fontSize: 9.5.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 9.5.sp, fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,

        items: [
          _buildCHATItem(0),
          _buildBOOKINGItem(1),
          _buildNOTIFICATIONItem(2),
          _buildProfileItem(3),
        ],
      ),
    );
  }



  BottomNavigationBarItem _buildCHATItem(int index) {
    return BottomNavigationBarItem(
      icon: Column(

        children: [
          // 🔵 Top line indicator
          Container(
            height: 4.h,
            width: 50.w,
            decoration: BoxDecoration(
              gradient: AppGradients.Projectgradient,
              color: _selectedindex == index ? null: Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 4.h),// Space between line and icon
          Image.asset(
            'assets/ICONS/CHAT_ICON.png',
            width: 24.w,
            height: 24.h,
            color: _getIconColor(index),
          ),
        ],
      ),
      label: "CHATS",
    );
  }

  BottomNavigationBarItem _buildBOOKINGItem(int index) {
    return BottomNavigationBarItem(
      icon: Column(

        children: [
          // 🔵 Top line indicator
          Container(
            height: 4.h,
            width: 50.w,
            decoration: BoxDecoration(
              gradient: AppGradients.Projectgradient,
              color: _selectedindex == index ? null: Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 4.h),// Space between line and icon
          Image.asset(
            'assets/ICONS/BOOKING_ICON.png',
            width: 24.w,
            height: 24.h,
            color: _getIconColor(index),
          ),
        ],
      ),
      label: "BOOKING",
    );
  }

  BottomNavigationBarItem _buildNOTIFICATIONItem(int index) {
    return BottomNavigationBarItem(
      icon: Column(

        children: [

          Container(
            height: 4.h,
            width: 50.w,
            decoration: BoxDecoration(
              gradient: AppGradients.Projectgradient,
              color: _selectedindex == index ? null: Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),// Space between line and icon



          Image.asset(
            'assets/ICONS/NOTIFICATION_ICON.png',
            width: 24.w,
            height: 24.h,
            color: _getIconColor(index),
          ),
        ]
        ,
      ),
      label: "NOTIFICATION",
    );
  }

  BottomNavigationBarItem _buildProfileItem(int index) {
    return BottomNavigationBarItem(
      icon: Column(

        children: [
          // 🔵 Top line indicator
          Container(
            height: 4.h,
            width: 50.w,
            decoration: BoxDecoration(
              gradient: AppGradients.Projectgradient,
              color: _selectedindex == index ? null: Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 4.h),// Space between line and icon

          CircleAvatar(
            radius: 15.r,
            backgroundImage: AssetImage('assets/IMAGES/Avatar_default.png'),
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
      label: "ACCOUNT",
    );
  }

  /// Function to get icon color based on selection.
  Color _getIconColor(int index) {
    return _selectedindex == index ? Color(0xFF156CD7) : Color(0xFF515978);
  }
}
