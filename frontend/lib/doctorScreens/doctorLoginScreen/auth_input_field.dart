import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────
// AuthInputField — Shared reusable form field widget
//
// WHY a shared widget instead of private _buildInputField()?
// Private builder methods (_buildInputField) live inside one
// screen's State class and cannot be reused by other screens.
// A shared StatelessWidget lives in the `widgets/` folder and
// is importable by PatientLoginScreen, DoctorLoginScreen,
// PatientSignupScreen — eliminating all duplication.
//
// Figma spec (identical across all auth screens):
//   Group 6: width 355 · height 73 · Left 20px
//   field bg: #F9FAFB · border: #E5E7EB · radius 12
//   prefix icon: teal #3ECCAF
//   hint text: Inter Regular 14px #6B7280
// ─────────────────────────────────────────────────────────────

class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Field label ──────────────────────────────────
        // Inter Regular 400 · 14px · #000000
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF000000),
              height: 1.0,
            ),
          ),
        ),

        // ── Input field ──────────────────────────────────
        // Height 52px (visual density matching Figma group height
        // of 73px: label 17px + gap 8px + field 48px ≈ 73px)
        SizedBox(
          height: 52,
          child: TextFormField(
            // WHY TextFormField?
            // Integrates with Form + GlobalKey so validate()
            // triggers every field's validator in one call.
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF000000),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF6B7280), // #6B7280
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB), // Figma field bg
              prefixIcon: Icon(
                prefixIcon,
                color: AppColors.primary, // teal #3ECCAF
                size: 20,
              ),
              suffixIcon: suffixIcon,
              // idle border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB), // Figma border
                  width: 1,
                ),
              ),
              // focused border → teal
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              // validation error border
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              errorStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.redAccent,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
