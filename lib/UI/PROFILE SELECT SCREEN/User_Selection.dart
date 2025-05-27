import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kidspath/UI/GOOGLE_MAPS/GOOGLE_MAPS_LOCATION.dart';
import 'package:kidspath/WIDGETS/GRADIENT_COLOR/gradient%20_color.dart';
import 'package:provider/provider.dart';
import '../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../DATA MODELS/Parent Model/Parent Model.dart';
import '../../THEME/theme_provider.dart';
import '../Create_Profile_screen/NURSERY/EditNurseryProfileScreen.dart';
import '../Create_Profile_screen/PARENT/EditProfileScreen.dart';



class RoleSelectionScreen extends StatefulWidget {
  final User user;

  RoleSelectionScreen({required this.user});

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = "";

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          selectedRole = "";
        });
      },
      child: Scaffold(appBar: AppBar(leading: IconButton(onPressed: (){
        SystemNavigator.pop();
      }, icon: Icon(Icons.arrow_back_ios_new_outlined)),),

          body: Padding(
            padding:  EdgeInsets.all(20.0),
            child: Column(
                children: [
                  SizedBox(height: 30.h,),
                  Expanded(// This centers the content vertically
                    child: Column(
                      mainAxisSize: MainAxisSize.min,// Ensures tight wrapping
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Continue as",
                              style:GoogleFonts.inter(fontSize: 40.sp, fontWeight: FontWeight.bold,
                              color:isDark?Colors.white:Colors.black ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),

                        Row(
                          children: [
                            Text(
                              "To continue to the next page, please\n"
                                  "select which one you are",
                              style: GoogleFonts.inter(fontSize: 15.sp,
                                  color:isDark?Colors.white:Colors.black ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h,),
                        //----------------------------------------------------------------------------///
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRole = "Parent";
                                  });
                                },
                                child: Container(
                                  height: 105.h,
                                  width: 354.95.w,
                                  decoration: BoxDecoration(
                                    gradient: selectedRole == "Parent"
                                        ? AppGradients.Projectgradient
                                        : null, // No gradient when not selected
                                    color: selectedRole == "Parent" ? null : Colors.white, // Default white color when not selected
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 30.r, // Avatar size
                                      backgroundColor: Color(0xFFEFEFF4), // Optional
                                      child: Container(
                                        width: 30.w,  // Custom width
                                        height:30.h, // Custom height
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage('assets/IMAGES/Icon User.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "Parent",
                                      style: GoogleFonts.inter(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: selectedRole == "Parent" ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "I am a parent/guardian\n "
                                          "seeking care",
                                      style: GoogleFonts.inter(fontSize: 15.sp,
                                          color: selectedRole == "Parent" ? Colors.white : Colors.black),
                                    ),
                                    trailing: selectedRole == "Parent"
                                        ? Icon(Icons.check_circle, color: Color(0xFF4CD964))
                                        : Icon(Icons.radio_button_unchecked,color:  Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRole = "Nursery";
                                  });
                                },

                                //////////////Nursery//////////////
                                child: Container(
                                  height: 105.h,
                                  width: 354.95.w,
                                  decoration: BoxDecoration(
                                    gradient: selectedRole == "Nursery"
                                        ? AppGradients.Projectgradient
                                        : null, // No gradient when not selected
                                    color: selectedRole == "Nursery" ? null : Colors.white, // Default white color when not selected
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 30.r, // Avatar size
                                      backgroundColor: Color(0xFFEFEFF4), // Optional
                                      child: Container(
                                        width: 30.w,  // Custom width
                                        height:30.h, // Custom height
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage('assets/IMAGES/nursery.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "Nursery",
                                      style: GoogleFonts.inter(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: selectedRole == "Nursery" ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "I am a preschool & day care provider",
                                      style: GoogleFonts.inter(fontSize: 15.sp,
                                          color: selectedRole == "Nursery" ? Colors.white : Colors.black),
                                    ),
                                    trailing: selectedRole == "Nursery"
                                        ? Icon(Icons.check_circle, color: Color(0xFF4CD964))
                                        : Icon(Icons.radio_button_unchecked,color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          ),

          //----------------------------------------------------------------------------------//

          //CONTINUE BUTTON BELOW
          bottomNavigationBar: Padding(
              padding: EdgeInsets.all(35.r),
              child: SizedBox(
                width: double.infinity,
                height: 60.h,
                child: ElevatedButton(
                  onPressed: () async {
                    await saveUserRole(widget.user.uid, selectedRole, widget.user.email);
                    if (selectedRole == "Parent") {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            parent: Parent(
                              uid: widget.user.uid,
                              name: widget.user.displayName ?? "",
                              email: widget.user.email ?? "",
                              role: "",
                              paymentCards: [],
                              location: "Location",
                              profileImageUrl: widget.user.photoURL,
                              phoneNumber:"",
                              Coordinates:GeoPoint(0.0, 0.0),

                            ),
                            role: selectedRole,
                            onProfileComplete: () {

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => GoogleMapsLocationx()),
                              );
                            }, fromRegistration: true,
                          ),
                        ),
                      );
                    }
                    if(selectedRole == "Nursery") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditNurseryProfileScreen(
                            nursery: NurseryProfile(
                              uid: widget.user.uid,
                              email: widget.user.email ?? '',
                              role: selectedRole,
                              name: "",
                              rating: 0.0,
                              description: "",
                              programs: [],
                              schedules: [],
                              calendar: "",
                              hours: "",
                              language: "",
                              price: "",
                              location: "",
                              Coordinates: GeoPoint(0.0, 0.0),
                              age: "",
                              averageRating: 0.0,
                              totalRatings: 0,
                              profileImageUrl: null,
                              phoneNumber: '',
                              ownerId: widget.user.uid,
                            ),
                            role: selectedRole,
                            onProfileComplete: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => GoogleMapsLocationx()),
                              );
                            },
                            fromRegistration: true,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient:AppGradients.Projectgradient,// My gradient colors
                      borderRadius: BorderRadius.circular(12.r),
                    ),

                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Continue",
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

              )
          )

      ),
    );
  }



  Future<void> saveUserRole(String uid, String role, String? email) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email ?? '',
      'role': role,
    }, SetOptions(merge: true));
  }
}