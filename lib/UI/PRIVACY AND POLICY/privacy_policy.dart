import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
      // Gradient Background for AppBar
      Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
        decoration: BoxDecoration(
          gradient: AppGradients.Projectgradient,
        ),),
    // Main Content with SafeArea
    SafeArea(
    child: Column(
    children: [
    // Transparent AppBar
    AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title:  Text('Privacy and Policy',
      style: GoogleFonts.inter(fontWeight: FontWeight.bold,color: Colors.white),),
    centerTitle: true,
    ),
    Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('1. Introduction'),
              _buildSectionContent(
                'Welcome to our app! We value your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and protect your information.',
              ),
              _buildSectionTitle('2. Information We Collect'),
              _buildSectionContent(
                'We may collect personal information including name, email, phone number, child data (for parents), location data, and payment information as needed to provide our services.',
              ),
              _buildSectionTitle('3. How We Use Your Information'),
              _buildSectionContent(
                'We use your information to:\n'
                    '- Provide and improve our services\n'
                    '- Personalize your experience\n'
                    '- Process transactions\n'
                    '- Send notifications and updates\n'
                    '- Ensure child safety and proper communication between users',
              ),
              _buildSectionTitle('4. Sharing of Information'),
              _buildSectionContent(
                'We do not share your personal information with third parties except:\n'
                    '- When required by law\n'
                    '- With trusted service providers (e.g., Firebase, payment processors)\n'
                    '- With other users for relevant app functions (e.g., nursery viewing parent details during booking)',
              ),
              _buildSectionTitle('5. Data Security'),
              _buildSectionContent(
                'We implement strict measures to protect your data from unauthorized access, alteration, or disclosure using secure cloud services and encryption where possible.',
              ),
              _buildSectionTitle('6. Your Rights'),
              _buildSectionContent(
                'You have the right to access, update, or delete your personal data. You can contact us for any requests regarding your information.',
              ),
              _buildSectionTitle('7. Changes to This Policy'),
              _buildSectionContent(
                'We may update this policy from time to time. You will be notified of any major changes through the app or email.',
              ),
              _buildSectionTitle('8. Contact Us'),
              _buildSectionContent(
                'If you have questions or concerns about our privacy practices, please contact us at:\n'
                    'Email: nursingscout@gmail.com',
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Last Updated: May 2025',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    ]))]));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8),
      child: Text(
        title,
        style:  GoogleFonts.inter(fontSize: 20.sp,fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: GoogleFonts.inter(fontSize: 12.sp,height: 1.5) ,
    );
  }
}
