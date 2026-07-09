import 'package:flutter/material.dart';

class AppColors {
  // ── Brand / Accent ──────────────────────────────────────────────────────
  static const Color ancientGold = Color(0xFFC9A84C);
  static const Color burnishedGold = Color(0xFFA8832A);
  static const Color paleGold = Color(0xFFE8D08A);
  static const Color bloodCrimson = Color(0xFF8B1A1A);
  static const Color emberRed = Color(0xFFC0392B);
  static const Color royalAmethyst = Color(0xFF6C3483);
  static const Color forestDeep = Color(0xFF1E4D2B);
  static const Color ironSteel = Color(0xFF4A5568);

  // ── Dark Mode Background & Surface (Primary Mode) ───────────────────────
  static const Color dungeonBlack = Color(0xFF0D0B08);
  static const Color obsidian = Color(0xFF1A1610);
  static const Color darkStone = Color(0xFF252018);
  static const Color weatheredStone = Color(0xFF312A1E);
  static const Color ironGray = Color(0xFF4A4235);
  static const Color agedBorder = Color(0xFF5C5040);

  // ── Dark Mode Text ───────────────────────────────────────────────────────
  static const Color parchmentWhite = Color(0xFFF0E6C8);
  static const Color fadedInk = Color(0xFFC4B896);
  static const Color dustyScript = Color(0xFF7A6E5A);

  // ── Light Mode (Parchment by Day) ────────────────────────────────────────
  static const Color agedParchment = Color(0xFFF2E8D0);
  static const Color vellum = Color(0xFFFAF4E4);
  static const Color oldMap = Color(0xFFE6D8B8);
  static const Color darkInk = Color(0xFF2A1F0E);
  static const Color brownInk = Color(0xFF5C4A2A);
  static const Color parchmentBorder = Color(0xFFC8B48A);

  // ── Status & Gameplay ────────────────────────────────────────────────────
  static const Color victoryGreen = Color(0xFF2E7D32);
  static const Color questGold = Color(0xFFF9A825);
  static const Color dangerRed = Color(0xFFC62828);
  static const Color manaBlue = Color(0xFF1565C0);
  static const Color legendaryPurple = Color(0xFF6A1B9A);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient darkGroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [dungeonBlack, obsidian, darkStone],
  );

  static const LinearGradient goldShimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [paleGold, ancientGold, burnishedGold],
  );

  static const LinearGradient stoneSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [weatheredStone, darkStone],
  );
}
