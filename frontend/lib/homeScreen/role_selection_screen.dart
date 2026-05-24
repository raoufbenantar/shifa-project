import 'package:flutter/material.dart';
import 'package:shifa/homeScreen/role_card.dart';
import 'package:shifa/homeScreen/user_role.dart';
import '../doctorScreens/doctorLoginScreen/doctor_login_screen.dart';
import '../patientScreens/patient_login_screen.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';


// ─────────────────────────────────────────────────────────────
// RoleSelectionScreen — "Welcome to Shifa"
//
// This is the app's entry screen.  The user picks their role
// (Patient or Doctor) which navigates to the correct login
// screen.  This is the root of the role-based navigation tree.
//
// Role-based navigation explained:
//   UserRole.patient → PatientLoginScreen
//                      → PatientSignupScreen (via Register link)
//                      → Patient Home (after login)
//
//   UserRole.doctor  → DoctorLoginScreen    ← NOW WIRED
//                      → DoctorSignupScreen (future)
//                      → Doctor Dashboard (after login)
//
// WHY Navigator.push (not pushReplacement)?
// Both login screens have a back arrow that must return here.
// push() keeps this screen alive on the stack so popping the
// login screen brings the user back without re-instantiation.
// ─────────────────────────────────────────────────────────────

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _onRoleSelected(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.patient:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PatientLoginScreen(),
          ),
        );
        break;

      case UserRole.doctor:
      // ── WHY pushes to DoctorLoginScreen now?
      // Previously this showed a SnackBar placeholder.
      // DoctorLoginScreen is now fully implemented with
      // its own BLoC, Use Case, and role-verification logic.
      // The screen's Use Case enforces role_id == 2 so a
      // patient account trying to log in here gets blocked
      // at the domain layer, never reaching the UI.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DoctorLoginScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Teal header ───────────────────────────────
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.33,
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.water_drop_outlined,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to Shifa',
                    style: AppTextStyles.welcomeTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose how you'll use the app",
                    style: AppTextStyles.welcomeSubtitle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ── White body ────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 28),

                  RoleCard(
                    icon: Icons.person_outline,
                    title: 'I am a Patient',
                    subtitle:
                    'Find care, book appointments\n'
                        '& manage your family\'s health',
                    onTap: () => _onRoleSelected(context, UserRole.patient),
                  ),

                  const SizedBox(height: 16),

                  RoleCard(
                    icon: Icons.medical_services_outlined,
                    title: 'I am a Doctor',
                    subtitle:
                    'Manage your practice,\n'
                        'patients & digital services',
                    onTap: () => _onRoleSelected(context, UserRole.doctor),
                  ),

                  const SizedBox(height: 28),
                  const Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: 10),

                  Text(
                    'Trusted by 50,000+ users',
                    style: AppTextStyles.trustedBy,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(value: '50K+',   label: 'Patients'),
                      _VerticalDivider(),
                      _StatItem(value: '1,200+', label: 'Doctors'),
                      _VerticalDivider(),
                      _StatItem(value: '98%',    label: 'Satisfaction'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'By continuing, you agree to our Terms & Privacy Policy',
                    style: AppTextStyles.termsText,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private stat widget ───────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.statNumber),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.statLabel),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.divider);
  }
}
