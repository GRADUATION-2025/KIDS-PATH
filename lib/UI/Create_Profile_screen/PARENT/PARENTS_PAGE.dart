import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kidspath/UI/GOOGLE_MAPS/GOOGLE_MAPS_LOCATION.dart';
import 'package:kidspath/WIDGETS/BOTTOM%20NAV%20BAR/BTM_BAR_NAV_PARENT.dart';
import 'package:provider/provider.dart';
import '../../../LOGIC/Parent/parent_cubit.dart';
import '../../../LOGIC/Parent/parent_state.dart';
import '../../../LOGIC/delete account/account_deletion_handler.dart';
import '../../../THEME/theme_provider.dart';
import '../../PRIVACY AND POLICY/privacy_policy.dart';
import 'CHILD/childData_screen.dart';
import '../../forget_change_password/forgetscreen.dart';
import 'EditProfileScreen.dart';

class ParentAccountScreen extends StatelessWidget {
  const ParentAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text("User not logged in"));
    }

    return BlocProvider(
      create: (context) => ParentCubit()..fetchParentData(user.uid),
      child: BlocConsumer<ParentCubit, ParentState>(
        listener: (context, state) {
          if (state is ParentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
          return Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.white,
            body: Padding(
              padding: EdgeInsets.only(top: 40.w),
              child: Builder(
                builder: (context) => _buildBody(context, state, user.uid),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ParentState state, String userId) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    if (state is ParentLoaded) {
      final parent = state.parent;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: BlocProvider.of<ParentCubit>(context),
                      child: EditProfileScreen(
                        parent: parent,
                        role: "Parent",
                        onProfileComplete: () {
                          context.read<ParentCubit>().fetchParentData(userId);
                        },
                        fromRegistration: false,
                      ),
                    ),
                  ),
                ).then((_) {
                  context.read<ParentCubit>().fetchParentData(userId);
                });
              },
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40.r,
                        backgroundImage: parent.profileImageUrl != null
                            ? NetworkImage(parent.profileImageUrl!)
                            : AssetImage('assets/profile.jpg') as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 12.r,
                          backgroundColor: isDark ? Colors.white : Colors.white,
                          child: Icon(Icons.edit, size: 16.sp, color: isDark ? Colors.blue[400] : Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parent.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        parent.email,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChildDataScreen()),
                );
              },
              leading: Icon(
                Icons.child_care,
                color: Colors.blue,
                size: 24,
              ),
              title: Text(
                "View Child Data",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ),

            Divider(
              height: 20.h,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            sectionTitle(context, "Account"),
            accountOption(
              context,
              Icons.lock,
              "Change Password",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
              ),
            ),
            accountOption(
              context,
              Icons.notifications,
              "Notifications",
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottombarParentScreen(initialIndex: 3,)),
                (route) => false,
              ),
            ),
            accountOption(context,Icons.privacy_tip, "Privacy and Policy",
                onTap: ()=> Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PrivacyPolicyScreen(),))),
            accountOption(
              context,
              Icons.logout,
              "Sign Out",
              onTap: () => AccountActionsHandler.signOut(context),
            ),
            accountOption(
              context,
              Icons.delete,
              "Delete Account",
              onTap: () => AccountActionsHandler.showDeleteDialog(context, userId, "Parent"),
              isDelete: true,
            ),
            Divider(
              height: 20.h,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            sectionTitle(context, "More Options"),
            toggleOption("Dark Mode", true),
            currencyOption(context, "Currency", "EGP"),
            currencyOption(context, "Languages", "English"),
            currencyOption(
              context,
              "Location",
              "Alexandria",
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => GoogleMapsLocationx()),
                (route) => false,
              ),
            ),
          ],
        ),
      );
    } else if (state is ParentError) {
      return Center(
        child: Text(
          state.message,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? Colors.blue[400] : Colors.blue,
        ),
      );
    }
  }

  Widget sectionTitle(BuildContext context, String title) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget accountOption(BuildContext context, IconData icon, String title, {VoidCallback? onTap, bool isDelete = false}) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return ListTile(
      leading: Icon(
        icon,
        color: isDelete
            ? (isDark ? Colors.blue[400] : Colors.blue)
            : (isDark ? Colors.blue[400] : Colors.blue),
        size: 28.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: isDark ? Colors.grey[400] : Colors.grey,
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget toggleOption(String title, bool isActive) {
    return Builder(
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        return ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          trailing: Switch(
            value: context.watch<ThemeProvider>().isDarkMode,
            activeColor: Color(0xFF0D41E1),
            onChanged: (value) => context.read<ThemeProvider>().toggleTheme(),
          ),
        );
      },
    );
  }

  Widget currencyOption(BuildContext context, String title, String value, {VoidCallback? onTap}) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 16.sp,
          color: isDark ? Colors.grey[400] : Colors.grey,
        ),
      ),
    );
  }
}