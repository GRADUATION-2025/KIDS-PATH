import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../home.dart';

class Bottombar extends StatefulWidget {
  final int initialIndex;

  const Bottombar({super.key, this.initialIndex = 0});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  late int _selectedindex;

  @override
  void initState() {
    super.initState();
    _selectedindex = widget.initialIndex;
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
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Color(0xFF156CD7),
        unselectedItemColor: Color(0xFF515978),
        type: BottomNavigationBarType.fixed,
        items: [
          _buildBottomNavItem(Icons.home_filled, "Home", 0),
          _buildImageNavItem("assets/ICONS/CHAT_ICON.png", "Chats", 1),
          _buildImageNavItem("assets/ICONS/BOOKING_ICON.png", "Booking", 2),
          _buildImageNavItem("assets/ICONS/NOTIFICATION_ICON.png", "Notifications", 3),
          _buildProfileNavItem(4),
        ],
      ),
    );
  }

  /// **Creates a BottomNavigationBarItem with an icon + text (No More Cut Text)**
  BottomNavigationBarItem _buildBottomNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: _iconWithLabel(Icon(icon, size: 24.sp), label, index),
      label: "",
    );
  }

  /// **Handles Image-based BottomNavigationBarItem**
  BottomNavigationBarItem _buildImageNavItem(String assetPath, String label, int index) {
    return BottomNavigationBarItem(
      icon: _iconWithLabel(
        Image.asset(assetPath, width: 22.w, height: 22.h),
        label,
        index,
      ),
      label: "",
    );
  }

  /// **Profile Navigation Item**
  BottomNavigationBarItem _buildProfileNavItem(int index) {
    return BottomNavigationBarItem(
      icon: _iconWithLabel(
        CircleAvatar(
          radius: 14.r,
          backgroundImage: AssetImage('assets/IMAGES/Avatar_default.png'),
        ),
        "Account",
        index,
      ),
      label: "",
    );
  }

  /// **✅ The Fix: Labels Always Show Fully Without Cutting**
  Widget _iconWithLabel(Widget icon, String label, int index) {
    return Container(
      width: MediaQuery.of(context).size.width / 5, // Ensures each item has enough space
      child: Row(
        mainAxisSize: MainAxisSize.max, // Takes full space
        mainAxisAlignment: MainAxisAlignment.center, // Centers the items
        children: [
          icon,
          if (_selectedindex == index) ...[
            SizedBox(width: 1.w),
            Flexible( // Allows text to use space properly
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF156CD7),
                ),
                overflow: TextOverflow.visible, // Ensures full visibility
                softWrap: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
