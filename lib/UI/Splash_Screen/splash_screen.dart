
// stars up and  down //
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../LOGIC/UserRole/auth_cubit.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
//   List<String> textList = [];
//   final String displayText = "Kids Path";  // Full text to be typed
//   int textIndex = 0;
//
//   late AnimationController _starAnimationController;
//   late Animation<double> _starAnimationTop;
//   late Animation<double> _starAnimationBottom;
//
//   @override
//   void initState() {
//     super.initState();
//     _startTypingAnimation();
//
//     // Animation controller for the stars
//     _starAnimationController = AnimationController(
//       duration: const Duration(seconds: 4),
//       vsync: this,
//     )..repeat(reverse: true);  // Repeats the animation back and forth
//
//     // Animation for top stars
//     _starAnimationTop = Tween<double>(begin: 0, end: 40).animate(
//       CurvedAnimation(
//         parent: _starAnimationController,
//         curve: Curves.easeInOut,  // Smooth up-and-down movement
//       ),
//     );
//
//     // Animation for bottom stars
//     _starAnimationBottom = Tween<double>(begin: 0, end: -40).animate(
//       CurvedAnimation(
//         parent: _starAnimationController,
//         curve: Curves.easeInOut,  // Smooth up-and-down movement
//       ),
//     );
//   }
//
//   // Function to trigger the typing animation
//   void _startTypingAnimation() {
//     // Split the text into individual characters
//     textList = displayText.split("");
//
//     // Typing animation: adds one character every 100 milliseconds
//     Timer.periodic(const Duration(milliseconds: 150), (timer) {
//       if (textIndex < textList.length) {
//         setState(() {
//           textIndex++;
//         });
//       } else {
//         timer.cancel();  // Stop the timer once all text is typed
//       }
//     });
//
//     // Navigate to the next screen after animation finishes
//     Future.delayed(const Duration(seconds: 6), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => AuthWrapper()),
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _starAnimationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Fun, child-friendly gradient background
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)], // Bright yellow to pink
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           // More stars: Animated stars at various positions
//           // Top-left stars
//           Positioned(
//             top: 120,
//             left: 30,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 800),
//               opacity: textIndex == displayText.length ? 1.0 : 0.0,
//               child: AnimatedScale(
//                 duration: const Duration(milliseconds: 800),
//                 scale: textIndex == displayText.length ? 1.2 : 0.0,
//                 child: Icon(
//                   Icons.star,  // Star icon
//                   size: 40,  // Size of the star
//                   color: Colors.white ,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 80,
//             left: 100,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 800),
//               opacity: textIndex == displayText.length ? 1.0 : 0.0,
//               child: AnimatedScale(
//                 duration: const Duration(milliseconds: 800),
//                 scale: textIndex == displayText.length ? 1.2 : 0.0,
//                 child: Icon(
//                   Icons.star,  // Star icon
//                   size: 40,  // Size of the star
//                   color: Colors.white ,
//                 ),
//               ),
//             ),
//           ),
//           // Top-right stars
//           Positioned(
//             top: 120,
//             right: 30,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 800),
//               opacity: textIndex == displayText.length ? 1.0 : 0.0,
//               child: AnimatedScale(
//                 duration: const Duration(milliseconds: 800),
//                 scale: textIndex == displayText.length ? 1.2 : 0.0,
//                 child: Icon(
//                   Icons.star,  // Star icon
//                   size: 40,  // Size of the star
//                   color: Colors.white ,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 60,
//             right: 80,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 800),
//               opacity: textIndex == displayText.length ? 1.0 : 0.0,
//               child: AnimatedScale(
//                 duration: const Duration(milliseconds: 800),
//                 scale: textIndex == displayText.length ? 1.5 : 0.0,
//                 child: Icon(
//                   Icons.star,  // Star icon
//                   size: 40,  // Size of the star
//                   color: Colors.white ,
//                 ),
//               ),
//             ),
//           ),
//           // Bottom-left stars
//           Positioned(
//             bottom: 120,
//             left: 30,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 800),
//               opacity: textIndex == displayText.length ? 1.0 : 0.0,
//               child: AnimatedScale(
//                 duration: const Duration(milliseconds: 800),
//                 scale: textIndex == displayText.length ? 1.2 : 0.0,
//                 child: Icon(
//                   Icons.star,  // Star icon
//                   size: 40,  // Size of the star
//                   color: Colors.white ,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 80,
//             left: 80,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 800),
//               opacity: textIndex == displayText.length ? 1.0 : 0.0,
//               child: AnimatedScale(
//                 duration: const Duration(milliseconds: 800),
//                 scale: textIndex == displayText.length ? 1.5 : 0.0,
//                 child: Icon(
//                   Icons.star,  // Star icon
//                   size: 40,  // Size of the star
//                   color: Colors.white ,
//                 ),
//               ),
//             ),
//           ),
//           // Bottom-right stars
//           Positioned(
//             bottom: 120,
//             right: 30,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 800),
//               opacity: textIndex == displayText.length ? 1.0 : 0.0,
//               child: AnimatedScale(
//                 duration: const Duration(milliseconds: 800),
//                 scale: textIndex == displayText.length ? 1.2 : 0.0,
//                 child: Icon(
//                   Icons.star,  // Star icon
//                   size: 40,  // Size of the star
//                   color: Colors.white ,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 60,
//             right: 80,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 800),
//               opacity: textIndex == displayText.length ? 1.0 : 0.0,
//               child: AnimatedScale(
//                 duration: const Duration(milliseconds: 800),
//                 scale: textIndex == displayText.length ? 1.5 : 0.0,
//                 child: Icon(
//                   Icons.star,  // Star icon
//                   size: 40,  // Size of the star
//                   color: Colors.white ,
//                 ),
//               ),
//             ),
//           ),
//
//           // Typing text animation (the app name)
//           Center(
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: List.generate(
//                 textIndex,  // Create a widget for each typed letter
//                     (index) {
//                   // Animate each character's appearance with bounce and opacity
//                   return AnimatedOpacity(
//                     duration: const Duration(milliseconds: 300),
//                     opacity: 1.0,
//                     child: AnimatedScale(
//                       duration: const Duration(milliseconds: 300),
//                       scale: 1.2,  // Slightly scale the letter for effect
//                       curve: Curves.elasticOut,  // More energetic bounce for kids
//                       child: AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 400),
//                         transitionBuilder: (Widget child, Animation<double> animation) {
//                           return ScaleTransition(
//                             scale: animation,
//                             child: child,
//                           );
//                         },
//                         child: Text(
//                           textList[index],
//                           key: ValueKey<int>(index),  // Unique key for transition
//                           style: GoogleFonts.pacifico(  // Playful font style for kids
//                             fontSize: 55,  // Large and fun text size
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             letterSpacing: 1.8,  // Letter spacing for readability
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




// stars up //


import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../LOGIC/UserRole/auth_cubit.dart';
import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import '../WELCOME SCREENS/Email Verify/Email Verify.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  List<String> textList = [];
  final String displayText = "Kids Path";  // Full text to be typed
  int textIndex = 0;

  late AnimationController _starAnimationController;
  late Animation<double> _starAnimation;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();

    // Animation controller for the stars
    _starAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);  // Repeats the animation back and forth

    _starAnimation = Tween<double>(begin: 0, end: 100).animate(
      CurvedAnimation(
        parent: _starAnimationController,
        curve: Curves.easeInOut,  // Smooth up-and-down movement
      ),
    );
  }

  // Function to trigger the typing animation
  void _startTypingAnimation() {
    textList = displayText.split("");

    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (textIndex < textList.length) {
        setState(() {
          textIndex++;
        });
      } else {
        timer.cancel();
      }
    });

    Future.delayed(const Duration(seconds: 6), () async {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();  // Ensure latest user info
      if (user != null && !user.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => EmailVerificationPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AuthWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _starAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fun, child-friendly gradient background
          Container(
            decoration: const BoxDecoration(
                gradient: AppGradients.Projectgradient
            ),
          ),
          // Multiple Animated Stars with up and down movement
          _buildAnimatedStar(40, 80, 1.2), // First star
          _buildAnimatedStar(120, 150, 0.8), // Second star
          _buildAnimatedStar(200, 50, 1.5), // Third star
          _buildAnimatedStar(300, 100, 1.3), // Fourth star
          _buildAnimatedStar(250, 200, 0.9), // Fifth star

          // Typing text animation
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                textIndex,  // Create a widget for each typed letter
                    (index) {
                  // Animate each character's appearance with bounce and opacity
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: 1.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: 1.2,  // Slightly scale the letter for effect
                      curve: Curves.elasticOut,  // More energetic bounce for kids
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          textList[index],
                          key: ValueKey<int>(index),  // Unique key for transition
                          style: GoogleFonts.pacifico(  // Playful font style for kids
                            fontSize: 55,  // Large and fun text size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.8,  // Letter spacing for readability
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build animated stars
  Widget _buildAnimatedStar(double left, double top, double scale) {
    return Positioned(
      top: top + _starAnimation.value,  // Adding the animated movement
      left: left,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 800),
        opacity: textIndex == displayText.length ? 1.0 : 0.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 800),
          scale: textIndex == displayText.length ? scale : 0.0,
          child: Icon(
            Icons.star,  // Star icon
            size: 50,  // Size of the star
            color: Colors.white ,
          ),
        ),
      ),
    );
  }
}


//
//
// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../LOGIC/UserRole/auth_cubit.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
//   List<String> textList = [];
//   final String displayText = "Kids Path";
//   int textIndex = 0;
//
//   late AnimationController _bgStarsController;
//
//   @override
//   void initState() {
//     super.initState();
//     _startTypingAnimation();
//
//     _bgStarsController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 4),
//     )..repeat(reverse: true);
//
//     Future.delayed(const Duration(seconds: 6), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => AuthWrapper()),
//       );
//     });
//   }
//
//   void _startTypingAnimation() {
//     textList = displayText.split("");
//     Timer.periodic(const Duration(milliseconds: 150), (timer) {
//       if (textIndex < textList.length) {
//         setState(() {
//           textIndex++;
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _bgStarsController.dispose();
//     super.dispose();
//   }
//
//   Widget _buildAnimatedStar({required double top, required double left, double size = 30, Color? color}) {
//     return AnimatedBuilder(
//       animation: _bgStarsController,
//       builder: (_, __) {
//         return Positioned(
//           top: top + sin(_bgStarsController.value * 2 * pi) * 10,
//           left: left + cos(_bgStarsController.value * 2 * pi) * 5,
//           child: Icon(
//             Icons.star,
//             color: color ?? Colors.white.withOpacity(0.8),
//             size: size,
//             shadows: [
//               Shadow(
//                 color: Colors.white.withOpacity(0.7),
//                 blurRadius: 12,
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screen = MediaQuery.of(context).size;
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background gradient
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//
//           // Multiple magical stars
//           _buildAnimatedStar(top: 80, left: 30, size: 40, color: Colors.white70),
//           _buildAnimatedStar(top: 100, left: screen.width - 60, size: 35),
//           _buildAnimatedStar(top: 180, left: 70, size: 25, color: Colors.white70),
//           _buildAnimatedStar(top: screen.height - 150, left: 40, size: 30),
//           _buildAnimatedStar(top: screen.height - 120, left: screen.width - 70, size: 40),
//           _buildAnimatedStar(top: screen.height / 2 + 120, left: 90, size: 25),
//           _buildAnimatedStar(top: screen.height / 2 + 160, left: screen.width - 100, size: 28),
//
//           // Center: animated app icon + text
//           Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 AnimatedOpacity(
//                   duration: const Duration(milliseconds: 800),
//                   opacity: textIndex == displayText.length ? 1.0 : 0.0,
//                   child: AnimatedScale(
//                     duration: const Duration(milliseconds: 800),
//                     scale: textIndex == displayText.length ? 1.3 : 0.0,
//                     curve: Curves.easeOutBack,
//                     child: Image.asset(
//                       'assets/IMAGES/app icon.png',
//                       width: 100,
//                       height: 100,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: List.generate(
//                     textIndex,
//                         (index) => AnimatedOpacity(
//                       duration: const Duration(milliseconds: 300),
//                       opacity: 1.0,
//                       child: AnimatedScale(
//                         duration: const Duration(milliseconds: 300),
//                         scale: 1.2,
//                         curve: Curves.elasticOut,
//                         child: AnimatedSwitcher(
//                           duration: const Duration(milliseconds: 400),
//                           transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
//                           child: Text(
//                             textList[index],
//                             key: ValueKey(index),
//                             style: GoogleFonts.pacifico(
//                               fontSize: 60,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               letterSpacing: 2.0,
//                               shadows: [
//                                 const Shadow(blurRadius: 6, color: Colors.black26, offset: Offset(2, 2)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
