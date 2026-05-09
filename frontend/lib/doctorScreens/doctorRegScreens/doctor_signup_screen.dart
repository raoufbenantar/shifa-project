import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shifa/doctorScreens/doctorRegScreens/register_doctor_usecase.dart';

import '../../../../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../doctorLoginScreen/auth_header.dart';
import '../doctorLoginScreen/auth_input_field.dart';
import 'doctor_signup_bloc.dart';
import 'doctor_signup_entity.dart';
import 'doctor_signup_event.dart';
import 'doctor_signup_remote_datasource.dart';
import 'doctor_signup_repository_impl.dart';
import 'doctor_signup_state.dart';


// ─────────────────────────────────────────────────────────────
// DoctorSignupScreen  —  "Doctor Details · Step 1 of 2"
//
// Figma spec (iPhone 13 & 14 – 5):
//   Header  : Group 3 · width 390 · height 187.57 · #3ECCAF
//             back arrow (arrow-left-circle) 31×31 · Left 30
//             "Doctor Details"  Inter Bold 700 · 28px · white
//             "Step 1 of 2"     Inter Regular 400 · 14px · white
//   Fields  : Frame 8 · 355×73 · Left 20
//             Labels → Inter Regular 400 · 14px · #000000
//             1. Full name       → Icons.person_outline   (24×24)
//             2. Phone Number    → Icons.phone_outlined    (+213…)
//             3. Email Address   → Icons.email_outlined
//             4. Specialization  → Icons.camera_alt_outlined
//             5. License Number  → Icons.credit_card_outlined
//             6. Password        → Icons.lock_outline + eye toggle
//   Button  : 230×61 · radius 21 · #3ECCAF
//             "Continue" · Inter Bold 700 · 26px · white
//             (text bounding box: 158×33)
//
// Reuses: AuthHeader, AuthInputField, AuthPrimaryButton
// Does NOT import: AuthSocialButton (not on this screen)
//
// Database alignment (FINAL_DIAGRAM):
//   users          → email, password_hash, role_id=2
//   doctor_profiles → full_name, phone_number, specialization
// ─────────────────────────────────────────────────────────────

// ── String constants ──────────────────────────────────────────
abstract class _S {
  static const headerTitle    = 'Doctor Details';
  static const headerSubtitle = 'Step 1 of 2';
  static const labelFullName  = 'Full name';
  static const labelPhone     = 'Phone Number';
  static const hintPhone      = '+213 XX XXX XXXX';
  static const labelEmail     = 'Email Address';
  static const labelSpec      = 'Specialization';
  static const labelLicense   = 'License Number';
  static const labelPassword  = 'Password';
  static const btnContinue    = 'Continue';
}

// ─────────────────────────────────────────────────────────────
// Entry widget — owns BlocProvider dependency wiring.
// WHY split DoctorSignupScreen + _DoctorSignupView?
//   • BlocProvider scopes the BLoC lifetime to this screen only.
//   • _DoctorSignupView is testable by injecting a mock BLoC.
// ─────────────────────────────────────────────────────────────
class DoctorSignupScreen extends StatelessWidget {
  const DoctorSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorSignupBloc(
        RegisterDoctorUseCase(
          DoctorSignupRepositoryImpl(
            DoctorSignupRemoteDataSourceMock(), // swap → real datasource
          ),
        ),
      ),
      child: const _DoctorSignupView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _DoctorSignupView — UI + local form state.
// ─────────────────────────────────────────────────────────────
class _DoctorSignupView extends StatefulWidget {
  const _DoctorSignupView();

  @override
  State<_DoctorSignupView> createState() => _DoctorSignupViewState();
}

class _DoctorSignupViewState extends State<_DoctorSignupView> {
  // ── Form key ──────────────────────────────────────────────
  // WHY GlobalKey<FormState>?
  // Calling _formKey.currentState!.validate() triggers every
  // field's validator simultaneously with one call on submit.
  final _formKey = GlobalKey<FormState>();

  // ── Controllers (one per field) ───────────────────────────
  // WHY separate controllers?
  // Each controller reads its field value independently when
  // the form submits.  The BLoC must not reach into widgets,
  // so the screen assembles the Entity from controller values.
  final _fullNameController    = TextEditingController();
  final _phoneController       = TextEditingController();
  final _emailController       = TextEditingController();
  final _specController        = TextEditingController();
  final _licenseController     = TextEditingController();
  final _passwordController    = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    // Dispose all controllers — prevents memory leaks when
    // the screen is removed from the navigation stack.
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specController.dispose();
    _licenseController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────
  // WHY validate in the screen AND in the Use Case?
  // The Form validator catches empty fields cheaply without a
  // network call.  The Use Case then runs deeper rules
  // (regex, min length) before touching the API.
  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;

    final entity = DoctorSignupEntity(
      fullName:       _fullNameController.text.trim(),
      phoneNumber:    _phoneController.text.trim(),
      email:          _emailController.text.trim(),
      specialization: _specController.text.trim(),
      licenseNumber:  _licenseController.text.trim(),
      password:       _passwordController.text,
    );

    context.read<DoctorSignupBloc>().add(DoctorSignupSubmitted(entity));
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // WHY BlocConsumer?
      // `listener` → one-time side-effects (navigation, SnackBar)
      // `builder`  → UI rebuild (spinner vs button label)
      // Using BlocBuilder alone for navigation causes it to
      // trigger multiple times as the framework rebuilds.
      body: BlocConsumer<DoctorSignupBloc, DoctorSignupState>(
        listener: _blocListener,
        builder:  _blocBuilder,
      ),
    );
  }

  // ── Listener — side-effects ───────────────────────────────
  void _blocListener(BuildContext context, DoctorSignupState state) {
    if (state is DoctorSignupSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please sign in.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate back to DoctorLoginScreen after success.
      // WHY popUntil instead of pushReplacement?
      // The login screen is already on the stack below
      // DoctorLoginScreen → DoctorSignupScreen.
      // Popping twice lands on DoctorLoginScreen cleanly.
      Navigator.pop(context); // back to DoctorLoginScreen
    }

    if (state is DoctorSignupFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ── Builder — pure UI ─────────────────────────────────────
  Widget _blocBuilder(BuildContext context, DoctorSignupState state) {
    final isLoading = state is DoctorSignupLoading;

    return Column(
      children: [
        // ════════════════════════════════════════════════
        // 1. TEAL HEADER
        // Figma Group 3: width 390 · height 187.57 · #3ECCAF
        // Uses shared AuthHeader widget (same as all auth screens).
        // WHY height 187.57?
        // Figma Group 3 specifies this exact value.  Using the
        // Figma measurement keeps the visual weight identical to
        // the PatientSignupScreen header.
        // ════════════════════════════════════════════════
        AuthHeader(
          title:    _S.headerTitle,     // "Doctor Details"
          subtitle: _S.headerSubtitle,  // "Step 1 of 2"
          height:   187.57,             // Figma Group 3 exact
        ),

        // ════════════════════════════════════════════════
        // 2. WHITE SCROLLABLE BODY + FORM
        // ════════════════════════════════════════════════
        Expanded(
          child: SingleChildScrollView(
            // WHY SingleChildScrollView?
            // 6 fields + button easily exceed the visible area
            // on small screens (SE, Mini).  Wrapping prevents
            // overflow without changing any field sizes.
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              // WHY Form widget wrapping all fields?
              // Form + GlobalKey allows _formKey.currentState!
              // .validate() to trigger every TextFormField's
              // validator in a single call on "Continue" tap.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── Field 1: Full name ────────────────
                  // Figma icon: "user" 24×24 · Left 43 · Top 236
                  AuthInputField(
                    controller: _fullNameController,
                    label:      _S.labelFullName,
                    hintText:   '',
                    prefixIcon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Full name is required'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // ── Field 2: Phone Number ─────────────
                  // Figma: phone icon · hint "+213 XX XXX XXXX"
                  AuthInputField(
                    controller:   _phoneController,
                    label:        _S.labelPhone,
                    hintText:     _S.hintPhone,
                    prefixIcon:   Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      return null; // deep check in UseCase
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Field 3: Email Address ────────────
                  AuthInputField(
                    controller:   _emailController,
                    label:        _S.labelEmail,
                    hintText:     '',
                    prefixIcon:   Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Field 4: Specialization ───────────
                  // Figma: camera_alt icon (closest to the
                  // medical-bag/specialization icon shown)
                  AuthInputField(
                    controller: _specController,
                    label:      _S.labelSpec,
                    hintText:   '',
                    prefixIcon: Icons.camera_alt_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Specialization is required'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // ── Field 5: License Number ───────────
                  // Figma: credit_card icon
                  AuthInputField(
                    controller: _licenseController,
                    label:      _S.labelLicense,
                    hintText:   '',
                    prefixIcon: Icons.credit_card_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'License number is required'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // ── Field 6: Password ─────────────────
                  // Eye-toggle suffix identical to DoctorLoginScreen.
                  AuthInputField(
                    controller:  _passwordController,
                    label:       _S.labelPassword,
                    hintText:    '',
                    prefixIcon:  Icons.lock_outline,
                    obscureText: _obscurePassword,
                    // WHY GestureDetector for the eye icon?
                    // The suffixIcon inside InputDecoration has no
                    // built-in tap callback.  GestureDetector wraps
                    // it cleanly and calls setState to toggle.
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── "Continue" button ─────────────────
                  // Figma: 230×61 · radius 21 · #3ECCAF
                  //        text "Continue" 158×33 · Bold 26px
                  // WHY use AuthPrimaryButton (which is 331px wide)?
                  // AuthPrimaryButton is a shared widget with a fixed
                  // 331px width.  The Figma shows 230px here, so we
                  // wrap it in a SizedBox to override the width.
                  // This keeps ALL button styling (radius, color,
                  // font, spinner) consistent — only the width differs.
                  Center(
                    child: SizedBox(
                      width: 230,  // Figma exact: 230px
                      height: 61,  // Figma exact: 61px
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, // #3ECCAF
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(21), // Figma r=21
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
                            : const Text(
                                _S.btnContinue,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700, // Bold 700
                                  fontSize: 26,               // Figma 26px
                                  color: AppColors.white,
                                  height: 1.0,
                                  letterSpacing: 0,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
