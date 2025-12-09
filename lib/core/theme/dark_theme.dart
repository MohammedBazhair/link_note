import 'package:flutter/material.dart';
import '../constants/colors/colors.dart';

ThemeData darkTheme() => ThemeData(
  scaffoldBackgroundColor: const Color(0xFF151825),
  brightness: Brightness.dark,
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: const Color(0xFF95B5B7),
  ),

  drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF151825)),
  appBarTheme: const AppBarThemeData(
    centerTitle: true,
    titleTextStyle: TextStyle(color: Colors.white),
    backgroundColor: Color(0xFF151825),
    iconTheme: IconThemeData(color: Colors.white),
    actionsPadding: EdgeInsets.symmetric(horizontal: 10),
    leadingWidth: 100,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      fixedSize: const Size.fromHeight(50),
      backgroundColor: DarkColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: const TextStyle(fontSize: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(
      color: const Color(0xFF95B5B7).withAlpha(200),
      fontSize: 13,
    ),
    filled: true,
    fillColor: const Color(0xFF2C324C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.transparent),
    ),
    contentPadding: const EdgeInsets.all(15),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(25),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.transparent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.transparent),
    ),
    outlineBorder: const BorderSide(color: Colors.transparent),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.transparent),
    ),
    errorStyle: const TextStyle(height: 3, color: Color(0xFFE4736B)),
  ),
  iconTheme: const IconThemeData(color: DarkColors.icon),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: DarkColors.icon,
      highlightColor: Colors.transparent,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xC45890F2),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xDF08284A),
    contentTextStyle: TextStyle(color: Color(0xD581E1E6)),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    circularTrackColor: Color(0xFF227FAA),
    color: Colors.white,
    refreshBackgroundColor: Color(0xFF043F52),
    linearTrackColor: Color(0xFF227FAA),
  ),
  listTileTheme: ListTileThemeData(
    tileColor: const Color(0xFF043F52),
    iconColor: DarkColors.icon,
    titleTextStyle: const TextStyle(
      color: Color(0xFFCFEBED),
      fontSize: 16,
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.ellipsis,
    ),
    subtitleTextStyle: const TextStyle(
      color: Color(0xFF95B5B7),
      overflow: TextOverflow.ellipsis,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: DarkColors.primary,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: Color(0xFF151825),
    barrierColor: Color(0x66292727),
  ),
  dividerTheme: const DividerThemeData(color: DarkColors.icon, thickness: 0.2),
);
