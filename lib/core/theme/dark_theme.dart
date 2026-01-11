import 'package:flutter/material.dart';
import '../constants/colors/colors.dart';
import '../constants/external_constants/external_constants.dart';

ThemeData darkTheme() => ThemeData(
  scaffoldBackgroundColor: const Color(0xFF151825),
  brightness: Brightness.dark,
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: const Color.fromARGB(255, 163, 235, 243),
  ),
  fontFamily: ExternalConsts.fontFamily,

  drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF151825)),
  appBarTheme: const AppBarThemeData(
    centerTitle: true,
    titleTextStyle: TextStyle(color: Colors.white),
    backgroundColor: Color(0xFF151825),
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.white),

    actionsPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
      hoverColor: Colors.transparent,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xC45890F2),
      overlayColor: Colors.transparent,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xDF08284A),
    contentTextStyle: TextStyle(color: Color(0xD581E1E6)),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: DarkColors.primary,
    linearTrackColor: Colors.transparent,
    circularTrackColor: Colors.transparent,

    borderRadius: BorderRadius.circular(18),
    strokeWidth: 2,
    linearMinHeight: 1,
  ),

  listTileTheme: ListTileThemeData(
    selectedTileColor: const Color(0xFF0C7395),
    selectedColor: Colors.grey.shade100,
    tileColor: Colors.transparent,
    titleTextStyle: const TextStyle(
      fontSize: 15,
      color: Color(0xFFCFEBED),
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.ellipsis,
    ),
    subtitleTextStyle: const TextStyle(
      color: DarkColors.secondFont,
      overflow: TextOverflow.ellipsis,
      fontSize: 13,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: DarkColors.primary,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: Color(0xFF151825),
    barrierColor: Color(0x66292727),
  ),
  dividerTheme: DividerThemeData(
    color: DarkColors.primary.withOpacity(0.2),
    thickness: 1,
  ),
  popupMenuTheme: PopupMenuThemeData(
    position: PopupMenuPosition.under,
    color: const Color(0xF022273C),
    elevation: 3,
    shadowColor: const Color(0xB8010101),
    menuPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xC55BD1FF),
    selectionHandleColor: DarkColors.primary,
    selectionColor: Color(0x335BD1FF),
  ),
);
