import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../home.dart';

class Bottombar2 extends StatefulWidget {
  final int initialIndex;

  const Bottombar2({super.key, this.initialIndex = 0}); // Default is Home

  @override
  State<Bottombar2> createState() => _Bottombar2State();
}

class _Bottombar2State extends State<Bottombar2> {
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
          Home(),
          Home(),
          Home(),
          Home(),
          Home(),
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
        unselectedItemColor: Color(0xFF515978),
        selectedLabelStyle: GoogleFonts.inter(fontSize: 9.5.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 9.5.sp, fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        items: [
          _buildBottomNavItem(Icons.home_filled, "HOME", 0),
          _buildCHATItem(1),
          _buildBOOKINGItem(2),
          _buildNOTIFICATIONItem(3),
          _buildProfileItem(4),
        ],
      ),
    );
  }

  /// Generic method to create BottomNavigationBarItem with an icon and a label.
  BottomNavigationBarItem _buildBottomNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24.w, color: _getIconColor(index)),
      label: label,
    );
  }

  BottomNavigationBarItem _buildCHATItem(int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        'assets/ICONS/CHAT_ICON.png',
        width: 24.w,
        height: 24.h,
        color: _getIconColor(index),
      ),
      label: "CHATS",
    );
  }

  BottomNavigationBarItem _buildBOOKINGItem(int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        'assets/ICONS/BOOKING_ICON.png',
        width: 24.w,
        height: 24.h,
        color: _getIconColor(index),
      ),
      label: "BOOKING",
    );
  }

  BottomNavigationBarItem _buildNOTIFICATIONItem(int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        'assets/ICONS/NOTIFICATION_ICON.png',
        width: 24.w,
        height: 24.h,
        color: _getIconColor(index),
      ),
      label: "NOTIFICATION",
    );
  }

  BottomNavigationBarItem _buildProfileItem(int index) {
    return BottomNavigationBarItem(
      icon: CircleAvatar(
        radius: 15.r,
        backgroundImage: AssetImage('assets/IMAGES/Avatar_default.png'),
        backgroundColor: Colors.transparent,
      ),
      label: "ACCOUNT",
    );
  }

  /// Function to get icon color based on selection.
  Color _getIconColor(int index) {
    return _selectedindex == index ? Color(0xFF156CD7) : Color(0xFF515978);
  }
}
