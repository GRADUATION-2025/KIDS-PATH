import 'package:flutter/material.dart';

class Notifcation_Screen extends StatefulWidget {
  const Notifcation_Screen({super.key});

  @override
  State<Notifcation_Screen> createState() => _Notifcation_ScreenState();
}

class _Notifcation_ScreenState extends State<Notifcation_Screen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("NOTIFICATIONS "),
          Text("UNDER DEVELOPMENT "),
        ],
      ),
    );
  }
}
