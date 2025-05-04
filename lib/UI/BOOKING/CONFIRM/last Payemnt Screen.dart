import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kidspath/WIDGETS/BOTTOM%20NAV%20BAR/BTM_BAR_NAV_PARENT.dart';

import '../../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';

class FinishPayemntScreen extends StatefulWidget {
  const FinishPayemntScreen({super.key});

  @override
  State<FinishPayemntScreen> createState() => _FinishPayemntScreenState();
}

class _FinishPayemntScreenState extends State<FinishPayemntScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
        gradient: AppGradients.Projectgradient
    ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40.h),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/IMAGES/kid.png', // Replace with your image
                  height: 120,
                ),
                SizedBox(width: 8.w),

              ],
            ),

            SizedBox(height: 60.h),


            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.check, size: 50, color: Colors.blue),
            ),

            SizedBox(height: 30),


            Text(
              'Congratulations',
              style: GoogleFonts.inter(
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 20),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'Thank you for choosing our service and trust our nursery to take care your lovely children',
                textAlign: TextAlign.center,
                style:GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: Colors.white

                ),
              ),
            ),

            Spacer(),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => BottombarParentScreen()),
                    (route)=>false);
                  },
                  child: Text('Close',

                    style:GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: Colors.black
                    ) ,),
                ),
              ),
            ),

    ])
      )
        )
    );
  }
}
