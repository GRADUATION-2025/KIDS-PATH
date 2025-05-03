import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient Projectgradient  = LinearGradient(
    colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );


  static const BoxDecoration buttonGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

}