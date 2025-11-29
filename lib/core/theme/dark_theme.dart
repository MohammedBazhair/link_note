import 'package:flutter/material.dart';
import 'package:link_note/core/constants/colors/colors.dart';

ThemeData darkTheme() => ThemeData(
  scaffoldBackgroundColor: Color(0xFF151825),
  brightness: Brightness.dark,
  textTheme: ThemeData.dark().textTheme.apply(bodyColor: Color(0xFF95B5B7)),

  drawerTheme: DrawerThemeData(backgroundColor: Color(0xFF151825)),
  appBarTheme: AppBarThemeData(
    centerTitle: true,
    titleTextStyle: TextStyle(color: Colors.white),
    backgroundColor: Color(0xFF151825),
    iconTheme: IconThemeData(color: Colors.white),
    actionsPadding: EdgeInsets.symmetric(horizontal: 10),
    leadingWidth: 100,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      fixedSize: Size.fromHeight(60),
      backgroundColor: DarkColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: TextStyle(fontSize: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: Color(0xFF95B5B7).withAlpha(200), fontSize: 13),
    filled: true,
    fillColor: Color(0xFF2C324C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: Colors.transparent),
    ),
    contentPadding: EdgeInsets.all(15),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(25),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: Colors.transparent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: Colors.transparent),
    ),
    outlineBorder: BorderSide(color: Colors.transparent),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: Colors.transparent),
    ),
    errorStyle: TextStyle(height: 3, color: const Color(0xFFE4736B)),
  ),
  iconTheme: IconThemeData(color: const Color(0x8550FFF6)),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0x8550FFF6),
      highlightColor: Colors.transparent,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xC45890F2),
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xDF08284A),
    contentTextStyle: TextStyle(color: const Color(0xD581E1E6)),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    circularTrackColor: const Color(0xFF227FAA),
    color: Colors.white,
  ),
);
