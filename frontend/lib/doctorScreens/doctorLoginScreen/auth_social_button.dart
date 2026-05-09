import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────
// AuthSocialButton — Google / Apple shared button
//
// Figma Rectangle 10 (same on all auth screens):
//   width 129 · height 39 · radius 15
//   bg #F9FAFB · border 1px #000000 @ 16% opacity
// ─────────────────────────────────────────────────────────────

class AuthSocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 129,  // Figma exact
        height: 39,  // Figma exact
        decoration: BoxDecoration(
          color: AppColors.socialButtonBg,         // #F9FAFB
          borderRadius: BorderRadius.circular(15), // Figma radius 15
          border: Border.all(
            color: AppColors.socialButtonBorder,   // #000000 @16%
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF000000)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
