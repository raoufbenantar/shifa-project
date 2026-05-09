import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────
// AuthHeader — Shared reusable widget
//
// WHY extract this into a shared widget?
// The teal header (back arrow + title + subtitle) is IDENTICAL
// in structure across PatientLoginScreen, DoctorLoginScreen,
// and PatientSignupScreen.  Before this refactor each screen
// duplicated ~40 lines of Container/Column/GestureDetector code.
//
// DRY principle: one change here (e.g. back arrow style) updates
// every auth screen simultaneously.
//
// Parameters:
//   title    → e.g. "Doctor Login", "Patient Login"
//   subtitle → e.g. "Manage your practice dashboard"
//   height   → Figma-exact header height per screen
//              Patient Login / Signup → 187px
//              Doctor Login           → 264px  ← Rectangle 1
// ─────────────────────────────────────────────────────────────

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.height = 187, // default matches patient screens
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,              // caller passes Figma-exact value
      color: AppColors.primary,   // #3ECCAF
      child: SafeArea(
        bottom: false,
        // WHY SafeArea only on top?
        // The header sits at the top of the screen and must
        // respect the device status bar / notch.  The bottom
        // is handled by the white body section independently.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Back arrow ────────────────────────────────
              // Figma: 36×36 circle · white border 1.5px
              // Consistent across all auth screens.
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),

              const Spacer(),

              // Title · Inter Bold · size passed from Figma
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700, // Bold
                  fontSize: 28,               // Figma doctor: 28px
                  color: AppColors.white,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle · Inter Regular 14px
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.white,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
