import 'package:flutter/material.dart';

ThemeData darkTheme() => ThemeData(
  scaffoldBackgroundColor: Color(0xFF101818),
  brightness: Brightness.dark,
  textTheme: ThemeData.dark().textTheme.apply(bodyColor: Color(0xFF95B5B7)),
  appBarTheme: AppBarThemeData(
    centerTitle: true,
    titleTextStyle: TextStyle(color: Colors.white),
    backgroundColor: Color(0xFF101818),
    iconTheme: IconThemeData(color: Colors.white),
    actionsPadding: EdgeInsets.symmetric(horizontal: 10),
    leadingWidth: 100,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      fixedSize: Size.fromHeight(60),
      backgroundColor: Color(0xFF27393A),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: TextStyle(fontSize: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: Color(0xFF95B5B7).withAlpha(200), fontSize: 13),
    filled: true,
    fillColor: Color(0xFF27393A),
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
  iconTheme: IconThemeData(color: const Color(0x858BD1D4)),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(backgroundColor: Color(0xFF00C2CC)),
  ),
);
