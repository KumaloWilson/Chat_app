import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    background: const Color.fromARGB(255, 20, 20, 20),
    primary: const Color.fromARGB(255, 105, 105, 105),
    secondary: const Color.fromARGB(255, 30, 30, 30),
    tertiary: const Color.fromARGB(255, 47, 47, 47),
    inversePrimary: Colors.grey.shade300,
  ),
);

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Colors.white,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
  ),
);

//------------------------------------------
//image paths
const String google = 'assets/images/google.png';

const String facebook = 'assets/images/Facebook.png';

//------------------------------------------

class AppColor {
  static Color kPrimary = const Color(0XFF5C99D0);
  static Color kBackGroundColor = const Color(0XFF2D3047);
  static Color kLightAccentColor = const Color(0XFFF4E5F7);
  static Color kGreyColor = const Color(0XFF939999);
  static Color kSamiDarkColor = const Color(0XFF313333);
  static Color kBlackColor = const Color(0XFF000000);
  static Color kWhiteColor = const Color(0XFFFFFFFF);
  static const Color kSecondary = Color(0xFF3F2D20);
  static const Color kBackground = Color(0xFFFFF5E0);
  static const Color kOrange = Color(0xFFEF8829);
  static const Color kRed = Colors.red;
  static const Color kLine = Color(0xFFE6DCCD);
}