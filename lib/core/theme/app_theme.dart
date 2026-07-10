import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── Dark Theme (Dungeon — primary) ────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.ancientGold,
        onPrimary: AppColors.dungeonBlack,
        secondary: AppColors.paleGold,
        onSecondary: AppColors.dungeonBlack,
        error: AppColors.dangerRed,
        onError: AppColors.parchmentWhite,
        surface: AppColors.darkStone,
        onSurface: AppColors.parchmentWhite,
      ),
      scaffoldBackgroundColor: AppColors.obsidian,
      dividerColor: AppColors.ironGray,

      // ── Typography ──────────────────────────────────────────────────────
      textTheme: TextTheme(
        // Cinzel — for epic display titles
        displayLarge: GoogleFonts.cinzel(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.parchmentWhite,
          letterSpacing: 1.5,
        ),
        displayMedium: GoogleFonts.cinzel(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.parchmentWhite,
          letterSpacing: 1.2,
        ),
        displaySmall: GoogleFonts.cinzel(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.parchmentWhite,
          letterSpacing: 0.8,
        ),
        // Inter — for readable UI text
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.parchmentWhite,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.6,
          color: AppColors.parchmentWhite,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.fadedInk,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.dustyScript,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.fadedInk,
        ),
      ),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dungeonBlack,
        foregroundColor: AppColors.parchmentWhite,
        elevation: 0,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.ancientGold,
          letterSpacing: 1.0,
        ),
        iconTheme: IconThemeData(color: AppColors.fadedInk),
        actionsIconTheme: IconThemeData(color: AppColors.fadedInk),
        surfaceTintColor: Colors.transparent,
      ),

      // ── Card ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.darkStone,
        elevation: 4,
        shadowColor: AppColors.dungeonBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.agedBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),

      // ── ElevatedButton (Gold Primary) ────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ancientGold,
          foregroundColor: AppColors.dungeonBlack,
          elevation: 2,
          shadowColor: AppColors.burnishedGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ancientGold,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.fadedInk,
          side: const BorderSide(color: AppColors.agedBorder, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),

      // ── Input ────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkStone,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.agedBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.agedBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.ancientGold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.fadedInk,
          fontSize: 13,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.dustyScript,
        ),
        prefixIconColor: AppColors.dustyScript,
        suffixIconColor: AppColors.dustyScript,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // ── BottomNavigationBar ───────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.dungeonBlack,
        selectedItemColor: AppColors.ancientGold,
        unselectedItemColor: AppColors.dustyScript,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.weatheredStone,
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.fadedInk,
          fontSize: 12,
        ),
        side: BorderSide(color: AppColors.agedBorder, width: 1),
        shape: StadiumBorder(),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Snackbar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.weatheredStone,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.parchmentWhite,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.agedBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.weatheredStone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.agedBorder),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.parchmentWhite,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.fadedInk,
        ),
      ),

      // ── FloatingActionButton ──────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.ancientGold,
        foregroundColor: AppColors.dungeonBlack,
        shape: CircleBorder(),
        elevation: 4,
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ancientGold,
        linearTrackColor: AppColors.ironGray,
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.dustyScript,
        textColor: AppColors.parchmentWhite,
        tileColor: Colors.transparent,
      ),
    );
  }

  // ── Light Theme (Parchment by Day) ──────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.burnishedGold,
        onPrimary: AppColors.darkInk,
        secondary: AppColors.ancientGold,
        onSecondary: AppColors.darkInk,
        error: AppColors.dangerRed,
        onError: Colors.white,
        surface: AppColors.vellum,
        onSurface: AppColors.darkInk,
      ),
      scaffoldBackgroundColor: AppColors.agedParchment,
      dividerColor: AppColors.parchmentBorder,

      // ── Typography ──────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.darkInk,
          letterSpacing: 1.5,
        ),
        displayMedium: GoogleFonts.cinzel(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.darkInk,
          letterSpacing: 1.2,
        ),
        displaySmall: GoogleFonts.cinzel(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.darkInk,
          letterSpacing: 0.8,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.darkInk,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.6,
          color: AppColors.darkInk,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.brownInk,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.brownInk,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.brownInk,
        ),
      ),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.oldMap,
        foregroundColor: AppColors.darkInk,
        elevation: 0,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.burnishedGold,
          letterSpacing: 1.0,
        ),
        iconTheme: IconThemeData(color: AppColors.brownInk),
        actionsIconTheme: IconThemeData(color: AppColors.brownInk),
        surfaceTintColor: Colors.transparent,
      ),

      // ── Card ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.vellum,
        elevation: 2,
        shadowColor: Color(0x44000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.parchmentBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),

      // ── ElevatedButton ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burnishedGold,
          foregroundColor: AppColors.darkInk,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.burnishedGold,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── Input ────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.vellum,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.parchmentBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.parchmentBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.burnishedGold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.brownInk,
          fontSize: 13,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.brownInk,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // ── BottomNavigationBar ───────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.oldMap,
        selectedItemColor: AppColors.burnishedGold,
        unselectedItemColor: AppColors.brownInk,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ── FloatingActionButton ──────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.burnishedGold,
        foregroundColor: AppColors.darkInk,
        shape: CircleBorder(),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.burnishedGold,
        linearTrackColor: AppColors.parchmentBorder,
      ),

      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.vellum,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.parchmentBorder),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkInk,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.brownInk,
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.oldMap,
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.brownInk,
          fontSize: 12,
        ),
        side: BorderSide(color: AppColors.parchmentBorder, width: 1),
        shape: StadiumBorder(),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Snackbar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.oldMap,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.darkInk,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.parchmentBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.brownInk,
        textColor: AppColors.darkInk,
        tileColor: Colors.transparent,
      ),
    );
  }
}
