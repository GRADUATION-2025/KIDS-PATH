import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kidspath/WIDGETS/BOTTOM%20NAV%20BAR/BTM_BAR_NAV_NURSERY.dart';
import 'package:provider/provider.dart';
import '../../../LOGIC/Nursery/nursery_cubit.dart';
import '../../../LOGIC/Nursery/nursery_state.dart';
import '../../../LOGIC/delete account/account_deletion_handler.dart';
import '../../../THEME/theme_provider.dart';
import '../../GOOGLE_MAPS/GOOGLE_MAPS_LOCATION.dart';
import '../../PRIVACY AND POLICY/privacy_policy.dart';
import '../../forget_change_password/forgetscreen.dart';
import 'EditNurseryProfileScreen.dart';
import 'NurseryProfileScreen.dart';

class NurseryAccountScreen extends StatelessWidget {
  const NurseryAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider
        .of<ThemeProvider>(context)
        .isDarkMode;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text("User not logged in"));
    }

    return BlocProvider(

      create: (context) =>
      NurseryCubit()
        ..fetchNurseryData(user.uid),
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        // // appBar: AppBar(
        // //   elevation: 0,
        // //   backgroundColor: Colors.white,
        //
        //   // actions: [
        //   //   IconButton(
        //   //     icon: Icon(Icons.more_vert, color: Colors.black),
        //   //     onPressed: () {},
        //   //   ),
        //   // ],
        // ),
        body: BlocConsumer<NurseryCubit, NurseryState>(
          listener: (context, state) {
            // Remove the NurseryUpdated check since it's not defined
            // The cubit will handle the state changes internally
          },
          builder: (context, state) {
            final isDark = Provider
                .of<ThemeProvider>(context)
                .isDarkMode;
            if (state is NurseryLoaded) {
              final nursery = state.nursery;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: kToolbarHeight),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditNurseryProfileScreen(
                                  nursery: nursery,
                                  role: "Nursery",
                                  onProfileComplete: () {
                                    // Simply fetch the data again after update
                                    context.read<NurseryCubit>()
                                        .fetchNurseryData(user.uid);
                                  }, fromRegistration: false,
                                ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              _UserAvatar(profileImageUrl: nursery.profileImageUrl),

                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 12.r,
                                  backgroundColor: isDark
                                      ? Colors.white
                                      : Colors.white,
                                  child: Icon(Icons.edit, size: 16.sp,
                                      color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nursery.name,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontSize: 20.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                nursery.email,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 13.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ListTile(
                      title: Text("View profile", style: TextStyle(fontSize: 16
                          .sp,
                          color: isDark ? Colors.white : Colors.black)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp,
                          color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NurseryProfileScreen(nursery: nursery),
                          ),
                        );
                      },
                    ),
                    Divider(height: 20.h),
                    sectionTitle(context, "Account"),
                    accountOption(context,
                      Icons.lock,
                      "Change Password",
                      onTap: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                ForgotPasswordScreen()),
                          ),
                    ),
                    accountOption(context, Icons.notifications, "Notifications",
                      onTap: () =>
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                BottombarNurseryScreen(initialIndex: 2,)),
                                (route) => false,
                          ),),
                    accountOption(
                        context, Icons.privacy_tip, "Privacy and Policy",
                        onTap: () =>
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    PrivacyPolicyScreen(),))),
                    accountOption(context,
                      Icons.logout,
                      "Sign Out",
                      onTap: () => AccountActionsHandler.signOut(context),
                    ),
                    accountOption(context,
                      Icons.delete,
                      "Delete Account",
                      onTap: () => AccountActionsHandler.showDeleteDialog(
                          context, user.uid, "Nursery"),
                    ),
                    Divider(height: 20.h),
                    sectionTitle(context, "More Options"),
                    toggleOption(context, "Dark Mode", true),
                    // toggleOption("Text Messages", false),
                    currencyOption(context, "Currency", "EGP"),
                    currencyOption(context, "Languages", "English"),
                    currencyOption(
                        context, "Location", "Alexandria", onTap: () =>
                        Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) =>
                              GoogleMapsLocationx(),), (route) => false,)),
                  ],
                ),
              );
            } else if (state is NurseryError) {
              return Center(child: Text(state.message));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget sectionTitle(BuildContext context, String title) {
    final isDark = Provider
        .of<ThemeProvider>(context)
        .isDarkMode;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Builder(
        builder: (context) =>
            Text(
                title,
                style: GoogleFonts.inter(
                    fontSize: 18.sp, fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black)
            ),
      ),
    );
  }

  Widget accountOption(BuildContext context, IconData icon, String title,
      {VoidCallback? onTap, bool isDelete = false}) {
    final isDark = Provider
        .of<ThemeProvider>(context)
        .isDarkMode;
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

  Widget toggleOption(BuildContext context, String title, bool isActive) {
    final isDark = Provider
        .of<ThemeProvider>(context)
        .isDarkMode;
    return Builder(
      builder: (context) =>
          ListTile(
            title: Text(title, style: TextStyle(fontSize: 16.sp,
                color: isDark ? Colors.white : Colors.black)),
            trailing: Switch(
              value: context
                  .watch<ThemeProvider>()
                  .isDarkMode,
              activeColor: Color(0xFF0D41E1),
              onChanged: (value) => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
    );
  }

  Widget currencyOption(BuildContext context, String title, String value,
      {VoidCallback? onTap}) {
    final isDark = Provider
        .of<ThemeProvider>(context)
        .isDarkMode;
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
  class _UserAvatar extends StatelessWidget {
  final String? profileImageUrl;

  const _UserAvatar({required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40.r,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: SizedBox(
          width: 80.w, // 2 * radius
          height: 80.h,
          child: CachedNetworkImage(
            imageUrl: profileImageUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Icon(
              Icons.person,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.person,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}


