import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────
// WHY a separate RoleCard widget?
// Both "I am a Patient" and "I am a Doctor"
// cards share identical structure, size, colours
// and behaviour.  Extracting them into a single
// reusable widget means we change layout/style
// in one place and both cards update instantly.
// ─────────────────────────────────────────────

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: onTap,
      child: Container(

        width: double.infinity,


        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary, // #3ECCAF
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 26,
              ),
            ),

            const SizedBox(width: 16),

            // ── Text block ────────────────────
            Expanded(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(height: 16),
                  // "I am a Patient"
                  // Inter · Medium · 16px · #000000
                  Text(title, style: AppTextStyles.cardTitle),

                  const SizedBox(height: 6),

                  // "Find care, book appointments…"
                  // Inter · Regular · 13px · #6B7280

                     Text(
                      subtitle,
                      style: AppTextStyles.cardSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
