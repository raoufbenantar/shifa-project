import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────
// AuthPrimaryButton — Shared reusable CTA button
//
// Figma Rectangle 9 (identical on all auth screens):
//   width 331 · height 61 · radius 21 · bg #3ECCAF
//   text: Inter Bold 700 · 26px · #FFFFFF
//
// WHY shared?
// The "Sign in" and "create account" buttons are visually
// identical.  One widget accepts a label + loading flag.
// ─────────────────────────────────────────────────────────────

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 331,  // Figma Rectangle 9 exact width
        height: 61,  // Figma Rectangle 9 exact height
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,         // #3ECCAF
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(21),  // Figma radius 21
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700, // Bold 700 — Figma
                    fontSize: 26,               // Figma 26px
                    color: AppColors.white,
                    height: 1.0,
                    letterSpacing: 0,
                  ),
                ),
        ),
      ),
    );
  }
}
