import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────
// Every text style is extracted directly from
// the Figma property panel so Flutter matches
// the design pixel-perfectly.
// ─────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  // ── Role-selection screen ─────────────────

  // "Welcome to Shifa" · Inter Bold 28px #FFFFFF
  static const TextStyle welcomeTitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontSize: 28,
    color: AppColors.white,
    height: 1.0,
    letterSpacing: 0,
  );

  // "Choose how you'll use the app" · Inter Regular 15px #FFFFFF
  static const TextStyle welcomeSubtitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: AppColors.white,
    height: 1.0,
    letterSpacing: 0,
  );

  // "I am a Patient" · Inter Medium 16px #000000
  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.cardTitle,
    height: 1.0,
    letterSpacing: 0,
  );

  // "Find care, book appointments…" · Inter Regular 13px #6B7280
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: AppColors.textSecondary,
    height: 1.0,
    letterSpacing: 0,
  );

  // "Trusted by 50,000+ users" · Inter ExtraLight 13px #6B7280
  static const TextStyle trustedBy = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w200,
    fontSize: 13,
    color: AppColors.textSecondary,
    height: 1.0,
    letterSpacing: 0,
  );

  // Stat numbers "50K+" · Inter Bold 16px #000000
  static const TextStyle statNumber = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: AppColors.statNumber,
    height: 1.0,
  );

  // Stat labels "Patients" · Inter Regular 12px #6B7280
  static const TextStyle statLabel = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.2,
  );

  // Terms footer · Inter Regular 11px #6B7280
  static const TextStyle termsText = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color: AppColors.textSecondary,
    height: 1.2,
  );

  // ── Login screen ──────────────────────────

  // "Patient Login" · Inter Bold 26px #FFFFFF
  static const TextStyle loginTitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontSize: 26,
    color: AppColors.white,
    height: 1.0,
    letterSpacing: 0,
  );

  // "Sign in to access your health portal" · Inter Regular 14px #FFFFFF
  static const TextStyle loginSubtitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.white,
    height: 1.0,
    letterSpacing: 0,
  );

  // Field labels "Phone Number" / "Password" · Inter Regular 14px #000000
  static const TextStyle fieldLabel = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.cardTitle,
    height: 1.0,
    letterSpacing: 0,
  );

  // Field placeholder · Inter Regular 14px #6B7280
  static const TextStyle fieldHint = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.0,
    letterSpacing: 0,
  );

  // "Sign in" button · Inter SemiBold 16px #FFFFFF
  static const TextStyle signInButton = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.white,
    height: 1.0,
    letterSpacing: 0,
  );

  // "or continue with" · Inter Regular 13px #6B7280
  static const TextStyle orContinue = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: AppColors.textSecondary,
    height: 1.0,
  );

  // Social button labels "Google" / "Apple" · Inter Regular 14px #000000
  static const TextStyle socialButton = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.cardTitle,
    height: 1.0,
  );

  // "Don't have an account?" · Inter Light 300 · 16px · #6B7280
  static const TextStyle registerPrompt = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w300,
    fontSize: 16,
    color: AppColors.textSecondary,
    height: 1.0,
  );

  // "Register" teal link · same size/weight as prompt
  static const TextStyle registerLink = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w300,
    fontSize: 16,
    color: AppColors.primary, // #3ECCAF
    height: 1.0,
  );
}
