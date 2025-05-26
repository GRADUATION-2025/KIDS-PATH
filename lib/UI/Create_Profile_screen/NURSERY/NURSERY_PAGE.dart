import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kidspath/WIDGETS/BOTTOM%20NAV%20BAR/BTM_BAR_NAV_NURSERY.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text("User not logged in"));
    }

    return BlocProvider(
      create: (context) => NurseryCubit()..fetchNurseryData(user.uid),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                            builder: (context) => EditNurseryProfileScreen(
                              nursery: nursery,
                              role: "Nursery",
                              onProfileComplete: () {
                                // Simply fetch the data again after update
                                context.read<NurseryCubit>().fetchNurseryData(user.uid);
                              }, fromRegistration: false,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 40.r,
                                backgroundImage: nursery.profileImageUrl != null
                                    ? NetworkImage(nursery.profileImageUrl!)
                                    : AssetImage('assets/nursery_default.png') as ImageProvider,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 12.r,
                                  backgroundColor: Theme.of(context).cardColor,
                                  child: Icon(Icons.edit, size: 16.sp, color: Colors.blue),
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
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                nursery.email,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ListTile(
                      title: Text("View profile", style: TextStyle(fontSize: 16.sp)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NurseryProfileScreen(nursery: nursery),
                          ),
                        );
                      },
                    ),
                    Divider(height: 20.h),
                    sectionTitle("Account"),
                    accountOption(
                      Icons.lock,
                      "Change Password",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                      ),
                    ),
                    accountOption(Icons.notifications, "Notifications",onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => BottombarNurseryScreen(initialIndex: 2,)),
                          (route) => false,
                    ),),
                    accountOption(Icons.privacy_tip, "Privacy and Policy",
                        onTap: ()=> Navigator.push(context,
                            MaterialPageRoute(builder: (context) => PrivacyPolicyScreen(),))),
                    accountOption(
                      Icons.logout,
                      "Sign Out",
                      onTap: () => AccountActionsHandler.signOut(context),
                    ),
                    accountOption(
                      Icons.delete,
                      "Delete Account",
                      onTap: () => AccountActionsHandler.showDeleteDialog(context, user.uid, "Nursery"),
                    ),
                    Divider(height: 20.h),
                    sectionTitle("More Options"),
                    toggleOption("Dark Mode", true),
                    // toggleOption("Text Messages", false),
                    currencyOption("Currency", "EGP"),
                    currencyOption("Languages", "English"),
                    currencyOption("Location", "Alexandria",onTap: () => Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) => GoogleMapsLocationx(),),(route) => false,)),
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

  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Builder(
        builder: (context) => Text(
          title, 
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Widget accountOption(IconData icon, String title, {VoidCallback? onTap}) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(icon, color: Colors.blue, size: 28.sp),
        title: Text(
          title, 
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16.sp)
        ),
        trailing: Icon(
          Icons.arrow_forward_ios, 
          size: 16.sp, 
          color: Theme.of(context).iconTheme.color?.withOpacity(0.5)
        ),
        onTap: onTap ?? () {},
      ),
    );
  }

  Widget toggleOption(String title, bool isActive) {
    return Builder(
      builder: (context) => ListTile(
        title: Text(title, style: TextStyle(fontSize: 16.sp)),
        trailing: Switch(
          value: context.watch<ThemeProvider>().isDarkMode,
          activeColor: Color(0xFF0D41E1),
          onChanged: (value) => context.read<ThemeProvider>().toggleTheme(),
        ),
      ),
    );
  }

  Widget currencyOption(String title, String value,{VoidCallback? onTap}) {
    return Builder(
      builder: (context) => ListTile(
        onTap: onTap,
        title: Text(
          title, 
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16.sp)
        ),
        trailing: Text(
          value, 
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp)
        ),
      ),
    );
  }
}