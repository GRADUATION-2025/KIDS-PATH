import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../LOGIC/Parent/parent_cubit.dart';
import '../../../LOGIC/Parent/parent_state.dart';
import '../../../LOGIC/delete account/account_deletion_handler.dart';
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
          return Scaffold(
           
            body: Padding(
              padding:  EdgeInsets.only(top: 40.w),
              child: _buildBody(context, state, user.uid),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ParentState state, String userId) {
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
                  // Refresh when returning from edit screen
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
                          backgroundColor: Colors.white,
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
                        parent.name,
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        parent.email,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChildDataScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.child_care,
                              color: Colors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "View Child Data",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

              ],

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
            accountOption(Icons.notifications, "Notifications"),
            accountOption(Icons.privacy_tip, "Privacy Settings"),
            accountOption(
              Icons.logout,
              "Sign Out",
              onTap: () => AccountActionsHandler.signOut(context),
            ),
            accountOption(
              Icons.delete,
              "Delete Account",
              onTap: () => AccountActionsHandler.showDeleteDialog(context, userId, "Parent"),
            ),
            Divider(height: 20.h),
            sectionTitle("More Options"),
            toggleOption("Newsletter", true),
            toggleOption("Text Messages", false),
            currencyOption("Currency", "EGP"),
            currencyOption("Languages", "English"),
            currencyOption("Location", "Alexandria"),
          ],
        ),
      );
    } else if (state is ParentError) {
      return Center(child: Text(state.message));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget accountOption(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue, size: 28.sp),
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }

  Widget toggleOption(String title, bool isActive) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      trailing: Switch(
        value: isActive,
        activeColor: Color(0xFF0D41E1),
        onChanged: (value) {},
      ),
    );
  }

  Widget currencyOption(String title, String value) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      trailing: Text(value, style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
    );
  }
}