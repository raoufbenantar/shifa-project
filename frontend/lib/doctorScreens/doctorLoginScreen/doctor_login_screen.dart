import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../doctorRegScreens/doctor_signup_screen.dart';
import 'auth_header.dart';
import 'auth_input_field.dart';
import 'auth_primary_button.dart';
import 'auth_social_button.dart';
import 'doctor_login_bloc.dart';
import 'doctor_login_event.dart';
import 'doctor_login_remote_datasource.dart';
import 'doctor_login_repository_impl.dart';
import 'doctor_login_state.dart';
import '../doctor_shell.dart';
import 'doctor_login_usecase.dart';



// ─────────────────────────────────────────────────────────────
// DoctorLoginScreen
//
// Figma: "Doctor Login" screen
//
// Visual spec (from screenshots):
//   Header    : Rectangle 1 · width 390 · height 264 · #3ECCAF
//               "Doctor Login"             Inter Bold 28px white
//               "Manage your practice…"   Inter Regular 14px white
//   Email field: Group 6 · 355×73 · Left 20 · radius 12
//   Password field: same
//   Sign in button: Rectangle 9 · 331×61 · radius 21 · #3ECCAF
//                   "Sign in" Inter Bold 700 26px white
//   Social row: Google + Apple · Rectangle 10 · 129×39 · r15
//   Footer: "Don't have an account? Register"
//           Inter Light 300 · 16px
//
// Database alignment (FINAL_DIAGRAM):
//   POST /auth/login → { email, password }
//   Response         → { token, user{ id, email, role_id=2,
//                        is_active, profile{ full_name,
//                        specialization, experience_years,
//                        consultation_fee, bio } } }
//   Tables           → users · doctor_profiles
// ─────────────────────────────────────────────────────────────

// ── String constants ──────────────────────────────────────────
// WHY an abstract class of constants?
// No magic strings anywhere in the widget tree.
// Update copy in ONE place; everything reflects it.
abstract class _Strings {
  static const headerTitle    = 'Doctor Login';
  static const headerSubtitle = 'Manage your practice dashboard';
  static const labelEmail     = 'Email Address';
  static const hintEmail      = '';
  static const labelPassword  = 'Password';
  static const hintPassword   = 'Enter password';
  static const btnSignIn      = 'Sign in';
  static const orContinue     = 'or continue with';
  static const google         = 'Google';
  static const apple          = 'Apple';
  static const noAccount      = "Don't have an account? ";
  static const register       = 'Register';
}

// ─────────────────────────────────────────────────────────────
// Entry widget — owns dependency injection via BlocProvider.
// ─────────────────────────────────────────────────────────────
class DoctorLoginScreen extends StatelessWidget {
  const DoctorLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // WHY wire dependencies inside the widget and not in main()?
      // Scoping the BLoC to this screen means it is created when
      // the screen is pushed and automatically closed (disposed)
      // when it is popped — no memory leaks, no stale state.
      create: (_) => DoctorLoginBloc(
        DoctorLoginUseCase(
          DoctorLoginRepositoryImpl(
            DoctorLoginRemoteDataSourceImpl(),
          ),
        ),
      ),
      child: const _DoctorLoginView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _DoctorLoginView — all UI + local form state.
// Kept private (underscore) → only DoctorLoginScreen can use it.
// ─────────────────────────────────────────────────────────────
class _DoctorLoginView extends StatefulWidget {
  const _DoctorLoginView();

  @override
  State<_DoctorLoginView> createState() => _DoctorLoginViewState();
}

class _DoctorLoginViewState extends State<_DoctorLoginView> {
  // ── Form ──────────────────────────────────────────────────
  final _formKey          = GlobalKey<FormState>();
  final _emailController  = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword   = true;

  @override
  void dispose() {
    // Always dispose controllers — prevents memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Submit handler ────────────────────────────────────────
  // Form validates first (empty-field check), then the BLoC
  // dispatches to the Use Case which runs the deeper business
  // rules (email regex, password length, role_id, is_active).
  void _onSignIn() {
    if (!_formKey.currentState!.validate()) return;

    context.read<DoctorLoginBloc>().add(
      DoctorLoginSubmitted(
        email:    _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<DoctorLoginBloc, DoctorLoginState>(
        // WHY BlocConsumer?
        // `listener` handles one-time side-effects (navigation,
        //  SnackBar).  `builder` handles UI shape (spinner vs
        //  button).  Splitting them avoids the classic bug of
        //  navigation being triggered multiple times because
        //  builder is called more than once by the framework.
        listener: _blocListener,
        builder:  _blocBuilder,
      ),
    );
  }

  // ── Listener ──────────────────────────────────────────────
  void _blocListener(BuildContext context, DoctorLoginState state) {
    if (state is DoctorLoginSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, ${state.doctor.fullName}!\n'
            '${state.doctor.specialization}',
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) =>
      const DoctorShell()));
      // pushReplacement removes the login screen from the stack
      // so the doctor can't press Back to return to login.
    }

    if (state is DoctorLoginFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ── Builder ───────────────────────────────────────────────
  Widget _blocBuilder(BuildContext context, DoctorLoginState state) {
    final isLoading = state is DoctorLoginLoading;

    return Column(
      children: [
        // ════════════════════════════════════════════════
        // 1. TEAL HEADER
        // Figma Rectangle 1: width 390 · height 264 · #3ECCAF
        // This is TALLER than the patient screens (187px)
        // because the doctor screen has no logo in the header
        // and the Figma explicitly sets 264px for this screen.
        // We use the shared AuthHeader widget with height: 264.
        // ════════════════════════════════════════════════
        const AuthHeader(
          title:    _Strings.headerTitle,    // "Doctor Login"
          subtitle: _Strings.headerSubtitle, // "Manage your practice…"
          height:   264,                     // Figma Rectangle 1 exact
        ),

        // ════════════════════════════════════════════════
        // 2. WHITE BODY
        // ════════════════════════════════════════════════
        Expanded(
          child: SingleChildScrollView(
            // WHY padding 20px horizontal?
            // Figma Left=20px for Group 6 (fields).
            // 390px canvas − 355px field = 35px → ~17.5px each side.
            // 20px is the clean standard margin that matches spec.
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  // ── Email field ───────────────────────
                  // Figma: Group 6 · 355×73 · Left 20px
                  // Uses shared AuthInputField widget —
                  // same dimensions/style as patient screens.
                  AuthInputField(
                    controller:   _emailController,
                    label:        _Strings.labelEmail,
                    hintText:     _Strings.hintEmail,
                    prefixIcon:   Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                      // Deep validation (regex) runs in LoginUseCase
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Password field ────────────────────
                  AuthInputField(
                    controller:    _passwordController,
                    label:         _Strings.labelPassword,
                    hintText:      _Strings.hintPassword,
                    prefixIcon:    Icons.lock_outline,
                    obscureText:   _obscurePassword,
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

                  const SizedBox(height: 36),

                  // ── Sign in button ────────────────────
                  // Shared AuthPrimaryButton:
                  //   331×61 · r21 · #3ECCAF · Bold 26px
                  AuthPrimaryButton(
                    label:     _Strings.btnSignIn,
                    isLoading: isLoading,
                    onPressed: _onSignIn,
                  ),

                  const SizedBox(height: 28),

                  // ── "or continue with" divider ────────
                  _buildOrDivider(),

                  const SizedBox(height: 20),

                  // ── Social buttons ────────────────────
                  // Shared AuthSocialButton: 129×39 · r15
                  _buildSocialRow(),

                  const SizedBox(height: 36),

                  // ── Register prompt ───────────────────
                  _buildRegisterPrompt(context),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // PRIVATE BUILDER HELPERS
  // ══════════════════════════════════════════════════════════

  Widget _buildOrDivider() {
    return const Row(
      children: [
        Expanded(
            child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _Strings.orContinue,
            style: AppTextStyles.orContinue,
          ),
        ),
        Expanded(
            child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AuthSocialButton(
          label: _Strings.google,
          icon:  Icons.g_mobiledata,
          onTap: () {
            // TODO: Google OAuth
          },
        ),
        const SizedBox(width: 16),
        AuthSocialButton(
          label: _Strings.apple,
          icon:  Icons.apple,
          onTap: () {
            // TODO: Apple Sign-In
          },
        ),
      ],
    );
  }

  // "Don't have an account? Register"
  // WHY WidgetSpan + GestureDetector over TextSpan recognizer?
  // TapGestureRecognizer must be manually disposed — easy to
  // forget → memory leak.  WidgetSpan is self-managed.
  Widget _buildRegisterPrompt(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.registerPrompt, // Light 300 · 16px · grey
          children: [
            const TextSpan(text: _Strings.noAccount),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorSignupScreen()));
                },
                child: const Text(
                  _Strings.register,
                  style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: AppColors.primary), // teal #3ECCAF
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
