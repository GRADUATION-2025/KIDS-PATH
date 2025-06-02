import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kidspath/WIDGETS/GRADIENT_COLOR/gradient%20_color.dart';
import 'package:provider/provider.dart';
import '../../LOGIC/booking/cubit.dart';
import '../../THEME/theme_provider.dart';
import '../../UI/BOOKING/bookingTime.dart';
import '../../UI/CHAT/chatList.dart';
import '../../UI/Create_Profile_screen/PARENT/PARENTS_PAGE.dart';
import '../../UI/HOME SCREEN/home.dart';
import '../../UI/NOTIFICATION/Notifcation.dart';
import '../notification badge/badge.dart';


class BottombarParentScreen extends StatefulWidget {
  final int initialIndex;

  const BottombarParentScreen({super.key, this.initialIndex = 0}); // Default is Home

  @override
  State<BottombarParentScreen> createState() => _BottombarParentScreenState();
}

class _BottombarParentScreenState extends State<BottombarParentScreen> {
  late int _selectedindex;
  String? profileImageUrl;
  final UserProfileService _profileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    _selectedindex = widget.initialIndex;
    _loadUserProfile();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedindex = index;
    });

    // Clear notifications when entering respective screens
    if (index == 1) { // Chat tab
      _clearChatNotifications();
    } else if (index == 2) { // Booking tab
      _clearBookingNotifications();
    } else if (index == 3) { // Notification tab
      _clearAllNotifications();
    }
  }


  Future<void> _clearChatNotifications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final messages = await FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': false});
    }
    await batch.commit();
  }


  Future<void> _clearBookingNotifications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final notifications = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'booking')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> _clearAllNotifications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final notifications = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final url = await _profileService.getProfileImageUrl(user.uid);
      if (mounted) {
        setState(() {
          profileImageUrl = url;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Scaffold(
      body: IndexedStack(
        index: _selectedindex,
        children: [
          HomeScreen(),
          ChatListScreen(),
          BlocProvider(
            create: (context) =>
            BookingCubit()
              ..initBookingsStream(isNursery: false),
            child: BookingTimesScreen(isNursery: false),
          ),
          NotificationScreen(),
          ParentAccountScreen(),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedindex,
        onTap: _onTabChanged,
        showSelectedLabels: true,
        // Show selected labels
        showUnselectedLabels: false,
        // Show unselected labels
        selectedItemColor: Color(0xFF156CD7),
        selectedIconTheme: IconThemeData(color: Colors.red),
        unselectedItemColor: Color(0xFF515978),
        selectedLabelStyle: GoogleFonts.inter(
            fontSize: 9.5.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 9.5.sp, fontWeight: FontWeight.bold),
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


  BottomNavigationBarItem _buildBottomNavItem(IconData icon, String label,
      int index) {
    return BottomNavigationBarItem(
      icon: Column(

        children: [
          // 🔵 Top line indicator
          Container(
            height: 4.h,
            width: 50.w,
            decoration: BoxDecoration(
              gradient: AppGradients.Projectgradient,
              color: _selectedindex == index ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 4.h), // Space between line and icon
          Icon(
            icon,
            size: 24.w,
            color: _getIconColor(index),
          ),
        ],
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _buildCHATItem(int index) {
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          Container(
            height: 4.h,
            width: 50.w,
            decoration: BoxDecoration(
              gradient: AppGradients.Projectgradient,
              color: _selectedindex == index ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),),
          SizedBox(height: 4.h),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('messages')
                .where('isRead', isEqualTo: false)
                .where('senderId', isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/ICONS/CHAT_ICON.png',
                    width: 24.w,
                    height: 24.h,
                    color: _getIconColor(index),
                  ),
                  if (count > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: BadgeCount(count: count, size: 18.w),
                    ),
                ],
              );
            },
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
          Container(
            height: 4.h,
            width: 50.w,
            decoration: BoxDecoration(
              gradient: AppGradients.Projectgradient,
              color: _selectedindex == index ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),),
          SizedBox(height: 4.h),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where('type', isEqualTo: 'booking')
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/ICONS/BOOKING_ICON.png',
                    width: 24.w,
                    height: 24.h,
                    color: _getIconColor(index),
                  ),
                  if (count > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: BadgeCount(count: count, size: 18.w),
                    ),
                ],
              );
            },
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
              color: _selectedindex == index ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),),
          SizedBox(height: 2.h),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/ICONS/NOTIFICATION_ICON.png',
                    width: 24.w,
                    height: 24.h,
                    color: _getIconColor(index),
                  ),
                  if (count > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: BadgeCount(count: count, size: 18.w),
                    ),
                ],
              );
            },
          ),
        ],
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
              color: _selectedindex == index ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 4.h), // Space between line and icon

          _UserAvatar(profileImageUrl: profileImageUrl),
        ],
      ),
      label: "ACCOUNT",
    );
  }

  /// Function to get icon color based on selection.
  Color _getIconColor(int index) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return _selectedindex == index
        ? Color(0xFF156CD7) // Selected color (blue)
        : isDark
        ? Colors.white! // Unselected in dark mode
        : Color(0xFF515978); // Unselected in light mode (default)
  }
}
class _UserAvatar extends StatelessWidget {
  final String? profileImageUrl;

  const _UserAvatar({required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Theme
          .of(context)
          .cardColor,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: profileImageUrl ?? '',
          width: 40.w,
          height: 40.h,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Icon(Icons.person, color: Theme
                  .of(context)
                  .iconTheme
                  .color
                  ?.withOpacity(0.5)),
          errorWidget: (context, url, error) =>
              Icon(Icons.person, color: Theme
                  .of(context)
                  .iconTheme
                  .color
                  ?.withOpacity(0.5)),
        ),
      ),
    );
  }
}

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getProfileImageUrl(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('parents').doc(uid).get();
      return userDoc['profileImageUrl']; // Assuming you store the URL in this field
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }
}