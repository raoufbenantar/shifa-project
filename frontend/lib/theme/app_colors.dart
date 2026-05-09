import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Single source of truth for every colour used
// in the app.  Values taken directly from the
// Figma property panel (Hex mode).
// ─────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Brand / Primary ───────────────────────
  // Figma: #3ECCAF  – header bg, icon fills,
  //                   card borders, Sign-in btn
  static const Color primary = Color(0xFF3ECCAF);

  // Pale mint card background fill
  static const Color primaryLight = Color(0xFFE8FAF6);

  // ── Text ──────────────────────────────────
  // Pure white used on the teal header
  static const Color white = Color(0xFFFFFFFF);

  // Card / field label title colour
  static const Color cardTitle = Color(0xFF000000);

  // Secondary / subtitle / placeholder colour · Figma: #6B7280
  static const Color textSecondary = Color(0xFF6B7280);

  // Bold stat numbers
  static const Color statNumber = Color(0xFF000000);

  // ── Surfaces ──────────────────────────────
  // Page background (white section below header)
  static const Color background = Color(0xFFFFFFFF);

  // Social button background · Figma Rectangle 10: #F9FAFB
  static const Color socialButtonBg = Color(0xFFF9FAFB);

  // Social button border · Figma: #000000 at 16% opacity → 0x29
  static const Color socialButtonBorder = Color(0x29000000);

  // Divider lines
  static const Color divider = Color(0xFFE5E7EB);
}
