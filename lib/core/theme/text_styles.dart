import 'package:flutter/material.dart';

class AppTextStyles {
  // Title style for the main welcome title
  static TextStyle titleStyle = TextStyle(
    fontSize: 80,
    fontWeight: FontWeight.w500,
    color: Colors.brown.shade900,
    height: 1.2,
  );
  
  // Subtitle style for instructions
  static TextStyle subtitleStyle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w500,
    color: Colors.brown.shade500,
    letterSpacing: 1.2,
  );
  
  // Button text style
  static TextStyle buttonStyle = TextStyle(
    fontFamily: "Jersey 10",
    fontSize: 40,
    fontWeight: FontWeight.w400,
    color: Colors.brown.shade700,
  );
  
  // Body text style for regular content
  static TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.brown.shade800,
  );
} 