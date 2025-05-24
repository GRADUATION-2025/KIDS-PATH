// import 'dart:async';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:kidspath/UI/PROFILE%20SELECT%20SCREEN/User_Selection.dart';
//
// class EmailVerificationPage extends StatefulWidget {
//   @override
//   _EmailVerificationPageState createState() => _EmailVerificationPageState();
// }
//
// class _EmailVerificationPageState extends State<EmailVerificationPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//
//   late Timer _verificationTimer;
//   Timer? _resendCooldownTimer;
//
//   bool _emailSent = false;
//   bool _isVerified = false;
//   int _resendCooldown = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _sendVerificationEmail();
//     _startEmailCheckTimer();
//   }
//
//   Future<void> _sendVerificationEmail() async {
//     final user = _auth.currentUser;
//     if (user != null && !user.emailVerified) {
//       await user.sendEmailVerification();
//       setState(() {
//         _emailSent = true;
//         _resendCooldown = 60;
//       });
//       _startResendCooldown();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Verification email sent to ${user.email}")),
//       );
//     }
//   }
//
//   void _startResendCooldown() {
//     _resendCooldownTimer?.cancel();
//     _resendCooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_resendCooldown == 0) {
//         timer.cancel();
//       } else {
//         setState(() {
//           _resendCooldown--;
//         });
//       }
//     });
//   }
//
//   void _startEmailCheckTimer() {
//     _verificationTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
//       final user = _auth.currentUser;
//       await user?.reload();
//       if (user != null && user.emailVerified) {
//         timer.cancel();
//
//
//         setState(() {
//           _isVerified = true;
//         });
//
//         await Future.delayed(Duration(seconds: 2));
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => RoleSelectionScreen(user: user)),
//         );
//       }
//     });
//   }
//
//
//
//   @override
//   void dispose() {
//     _verificationTimer.cancel();
//     _resendCooldownTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Verify Your Email")),
//       body: Center(
//         child: _isVerified
//             ? Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 20),
//             Text("Verified! Redirecting...", style: TextStyle(fontSize: 18)),
//           ],
//         )
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.email_outlined, size: 100, color: Colors.blue),
//             SizedBox(height: 20),
//             Text(
//               "We've sent a verification link to your email.\nPlease verify and return.",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _resendCooldown == 0 ? _sendVerificationEmail : null,
//               icon: Icon(Icons.refresh),
//               label: Text(_resendCooldown == 0
//                   ? "Resend Email"
//                   : "Resend in $_resendCooldown s"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


  import 'dart:async';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:kidspath/UI/PROFILE%20SELECT%20SCREEN/User_Selection.dart';


  class EmailVerificationPage extends StatefulWidget {
    @override
    _EmailVerificationPageState createState() => _EmailVerificationPageState();
  }

  class _EmailVerificationPageState extends State<EmailVerificationPage> {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    late Timer _timer;
    bool _emailSent = false;
    bool _isVerified = false;
    int _resendCooldown = 60;
    late Timer _cooldownTimer;
    bool _canResend = false;

    @override
    void initState() {
      super.initState();
      _setVerificationFlag();
      _sendVerificationEmail();
      _startEmailCheckTimer();
      _startResendCooldown();
    }

    Future<void> _setVerificationFlag() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('emailNotVerified', true);
    }

    Future<void> _removeVerificationFlag() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('emailNotVerified');
    }

    Future<void> _sendVerificationEmail() async {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _emailSent = true;
          _canResend = false;
          _resendCooldown = 60;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification email sent to ${user.email}")),
        );
        _startResendCooldown();
      }
    }

    void _startResendCooldown() {
      _cooldownTimer = Timer.periodic(Duration(seconds: 2), (timer) {
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) {
            _canResend = true;
            _cooldownTimer.cancel();
          }
        });
      });
    }

    void _startEmailCheckTimer() {
      _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
        final user = _auth.currentUser;
        await user?.reload();
        if (user != null && user.emailVerified) {
          _timer.cancel();
          _cooldownTimer.cancel();
          setState(() {
            _isVerified = true;
          });



          await _removeVerificationFlag();
          await Future.delayed(Duration(seconds: 2));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RoleSelectionScreen(user: user)),
          );
        }
      });
    }

    @override
    void dispose() {
      _timer.cancel();
      _cooldownTimer.cancel();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("Verify Your Email")),
        body: Center(
          child: _isVerified
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20.h),
              Text("Verified! Redirecting...", style: TextStyle(fontSize: 18.sp)),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 100, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                "We've sent a verification link to your email.\nPlease verify and return.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.sp),
              ),
              SizedBox(height: 30.h),
              ElevatedButton.icon(
                onPressed: _canResend ? _sendVerificationEmail : null,
                icon: Icon(Icons.refresh),
                label: Text(_canResend
                    ? "Resend Email"
                    : "Resend in $_resendCooldown sec"),
              ),
            ],
          ),
        ),
      );
    }
  }
