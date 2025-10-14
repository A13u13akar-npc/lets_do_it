import 'package:flutter/material.dart';

// Define custom colors
const Color customPurple = Color(0xFF378FFF);
const Color customDarkGreybg = Color(0xFF181A20);
const Color customWhitebg = Color(0xFFFFFFFF);
const Color customDarkTextContainer = Color(0xFF1F222A);
const Color customDarkContainerOutline = Color(0xFF414454);

// Light theme definition
final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: customWhitebg,
  brightness: Brightness.light,
  textTheme: const TextTheme(),
  iconTheme: const IconThemeData(color: customPurple),
);

// Dark theme definition
final ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: customDarkGreybg,
  brightness: Brightness.dark,
  iconTheme: const IconThemeData(color: Colors.white),
);
