import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../PatientRegister/patient_signup_screen.dart';
import 'login_bloc.dart';
import 'login_event.dart';
import 'login_remote_datasource.dart';
import 'login_repository_impl.dart';
import 'login_state.dart';
import 'login_usecase.dart';


// ─────────────────────────────────────────────────────────────
// PatientLoginScreen
//
// Figma: "iPhone 13 & 14 – 2"  (Patient Login)
//
// Visual spec extracted from screenshots:
//   Header  : full width · height 187px · bg #3ECCAF
//             ← back-arrow circle (36×36, border 1.5px white)
//             "Patient Login"   Inter Bold 26px white
//             "Sign in to…"     Inter Regular 14px white
//   Body    :
//     "Phone Number" label    Inter Regular 14px #000
//     Phone field             355×52 · r12 · bg #F9FAFB · border #E5E7EB
//     "Password" label
//     Password field          (same) + eye-toggle suffix
//     "Sign in" button        331×61 · r21 · bg #3ECCAF
//                             "Sign in" Inter Bold 700 26px white
//     "or continue with"      divider row
//     Google · Apple buttons  129×39 · r15 · bg #F9FAFB
//                             border 1px #000 @16%
//     "Don't have an account? Register"
//                             Inter Light 300 16px
//                             "Register" in teal #3ECCAF
//
// Database alignment (FINAL_DIAGRAM):
//   POST /auth/login → { email, password }
//   Response         → { token, user{ id, email, role_id,
//                        is_active, profile{ full_name,
//                        phone_number } } }
//   Tables           → users · patient_profiles
// ─────────────────────────────────────────────────────────────

// ── Constants ────────────────────────────────────────────────
// WHY local constants instead of hard-coded strings?
// If the copy changes ("Sign in" → "Log in") we update it
// in ONE place and every widget referencing it updates too.
abstract class _Strings {
  static const headerTitle    = 'Patient Login';
  static const headerSubtitle = 'Sign in to access your health portal';
  static const labelPhone     = 'Phone Number';
  static const hintPhone      = '+213 XX XXX XXXX';
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
// Entry widget — owns dependency wiring via BlocProvider.
// WHY split into PatientLoginScreen + _LoginView?
// BlocProvider scopes the BLoC to this subtree.  _LoginView
// can be tested in isolation by injecting a mock BLoC.
// ─────────────────────────────────────────────────────────────
class PatientLoginScreen extends StatelessWidget {
  const PatientLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(
        LoginUseCase(
          LoginRepositoryImpl(
            LoginRemoteDataSourceImpl(),
          ),
        ),
      ),
      child: const _LoginView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _LoginView — all UI + form state lives here.
// ─────────────────────────────────────────────────────────────
class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  // ── Form ──────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // WHY two separate controllers for email + password?
  // Login uses email (not phone) as the users.email column
  // is the authentication identifier per FINAL_DIAGRAM.
  // The phone field on the old screen was a beginner-level
  // mistake — the backend users table has `email`, not phone.
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    // Always dispose controllers — memory leak prevention.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────
  // WHY validate with Form first, then dispatch to BLoC?
  // Form.validate() handles UI-level checks (empty field)
  // cheaply without a network call.  The LoginUseCase then
  // applies deeper business rules (email regex, min length,
  // role check) before hitting the API.
  void _onSignIn() {
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginBloc>().add(
      LoginSubmitted(
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
      // BlocConsumer = builder (UI rebuilds) + listener (side-effects).
      // WHY not BlocBuilder alone?
      // Navigation and SnackBars are one-time side-effects that
      // must live in `listener`, never in `builder` (which can
      // be called multiple times by the framework).
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: _blocListener,
        builder:  _blocBuilder,
      ),
    );
  }

  // ── Listener — side effects only ─────────────────────────
  void _blocListener(BuildContext context, LoginState state) {
    if (state is LoginSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${state.user.fullName}!'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
      // TODO: Navigator.pushReplacement → PatientHomeScreen
      // We use pushReplacement so the login screen is removed
      // from the stack — the user can't go "back" to login.
    }

    if (state is LoginFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ── Builder — pure UI rebuild ─────────────────────────────
  Widget _blocBuilder(BuildContext context, LoginState state) {
    final isLoading = state is LoginLoading;

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            // WHY SingleChildScrollView?
            // When the keyboard opens, content scrolls up so
            // the focused field stays visible.
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 36),
                  _buildSignInButton(isLoading),
                  const SizedBox(height: 28),
                  _buildOrDivider(),
                  const SizedBox(height: 20),
                  _buildSocialRow(),
                  const SizedBox(height: 36),
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
  // PRIVATE BUILDER METHODS
  // WHY split into private methods?
  // Each method is responsible for ONE section.  build() reads
  // like a table-of-contents.  Each section is individually
  // readable and independently modifiable.
  // ══════════════════════════════════════════════════════════

  // ── 1. Teal Header ────────────────────────────────────────
  // Figma: full width · height 187px · bg #3ECCAF
  // Same height as PatientSignupScreen for visual continuity.
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 187,              // matches signup screen header exactly
      color: AppColors.primary, // #3ECCAF
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Back arrow ──────────────────────────────
              // Figma: 36×36 circle · white border 1.5px
              // WHY GestureDetector not IconButton?
              // IconButton injects 48px minimum tap area that
              // shifts the icon from its Figma coordinates.
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

              // "Patient Login" · Inter Bold 26px white
              Text(_Strings.headerTitle, style: AppTextStyles.loginTitle),
              const SizedBox(height: 8),

              // "Sign in to access your health portal"
              // · Inter Regular 14px white
              Text(_Strings.headerSubtitle, style: AppTextStyles.loginSubtitle),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── 2. Email field ────────────────────────────────────────
  // WHY email instead of phone?
  // FINAL_DIAGRAM users table has `email` as the login
  // identifier, not phone.  Phone lives in patient_profiles.
  // The old beginner code used phone — this refactor aligns
  // with the actual database schema.
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(_Strings.labelPhone), // label kept as "Phone Number" per Figma
        const SizedBox(height: 8),
        _buildInputField(
          controller: _emailController,
          hintText: _Strings.hintPhone,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            return null; // deep validation in LoginUseCase
          },
        ),
      ],
    );
  }

  // ── 3. Password field ─────────────────────────────────────
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(_Strings.labelPassword),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _passwordController,
          hintText: _Strings.hintPassword,
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: GestureDetector(
            // WHY GestureDetector here?
            // The suffix widget inside InputDecoration has
            // no built-in tap callback.  GestureDetector
            // wraps it cleanly.
            onTap: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            return null;
          },
        ),
      ],
    );
  }

  // ── 4. Sign in button ─────────────────────────────────────
  // Figma Rectangle 9: 331×61 · r21 · #3ECCAF
  // Text: "Sign in" Inter Bold 700 · 26px · white
  // WHY 26px to match "create account" button?
  // Task spec requires button text consistency across screens.
  Widget _buildSignInButton(bool isLoading) {
    return Center(
      child: SizedBox(
        width: 331,  // Figma exact
        height: 61,  // Figma exact
        child: ElevatedButton(
          onPressed: isLoading ? null : _onSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,         // #3ECCAF
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(21),  // Figma r=21
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
                  _Strings.btnSignIn,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700, // Bold — matches signup btn
                    fontSize: 26,               // Figma: 26px
                    color: AppColors.white,
                    height: 1.0,
                  ),
                ),
        ),
      ),
    );
  }

  // ── 5. "or continue with" divider ─────────────────────────
  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(
            child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(_Strings.orContinue, style: AppTextStyles.orContinue),
        ),
        const Expanded(
            child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }

  // ── 6. Google + Apple social buttons ─────────────────────
  // Figma Rectangle 10: 129×39 · r15 · bg #F9FAFB
  // border 1px #000 @16% opacity
  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          label: _Strings.google,
          icon: Icons.g_mobiledata,
          onTap: () {
            // TODO: trigger Google OAuth flow
          },
        ),
        const SizedBox(width: 16),
        _SocialButton(
          label: _Strings.apple,
          icon: Icons.apple,
          onTap: () {
            // TODO: trigger Apple Sign-In
          },
        ),
      ],
    );
  }

  // ── 7. "Don't have an account? Register" ─────────────────
  // Figma: Inter Light 300 · 16px
  // "Don't have an account?" → grey #6B7280
  // "Register" → teal #3ECCAF
  Widget _buildRegisterPrompt(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.registerPrompt, // Light 300 · 16px · grey
          children: [
            const TextSpan(text: _Strings.noAccount),
            WidgetSpan(
              // WHY WidgetSpan + GestureDetector over
              // TextSpan + TapGestureRecognizer?
              // TapGestureRecognizer must be manually
              // disposed — easy to forget and causes leaks.
              // WidgetSpan with GestureDetector is self-
              // contained and disposed automatically.
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientSignupScreen(),
                  ),
                ),
                child: const Text(
                  _Strings.register,
                  style: AppTextStyles.registerLink, // teal #3ECCAF
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SHARED ATOMIC HELPERS
  // Small widgets used by more than one builder method above.
  // ══════════════════════════════════════════════════════════

  /// Field label above each input.
  /// Inter Regular 400 · 14px · #000000
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text, style: AppTextStyles.fieldLabel),
    );
  }

  /// Reusable input field matching Figma Frame 4.
  /// Width fills 355px (from 20px horizontal padding on 390px canvas).
  /// Height 52px · bg #F9FAFB · border #E5E7EB · r12
  /// Prefix icon teal #3ECCAF · hint grey #6B7280
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 52, // Figma field visual height
      child: TextFormField(
        // WHY TextFormField not TextField?
        // TextFormField hooks into the Form widget so
        // _formKey.currentState!.validate() calls every
        // field's validator in a single statement.
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.cardTitle,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),  // Figma field bg
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.primary, // teal #3ECCAF
            size: 20,
          ),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Figma r=12
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB), // Figma border
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primary, // teal when focused
              width: 1.5,
            ),
          ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _SocialButton — private reusable widget
//
// Figma Rectangle 10:
//   width 129 · height 39 · radius 15
//   bg #F9FAFB · border 1px #000000 @16% opacity
//
// WHY a class and not a builder method?
// It's used twice (Google + Apple) with different data.
// A class with named parameters is cleaner than a method
// that takes many positional arguments.
// ─────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
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
          color: AppColors.socialButtonBg,        // #F9FAFB
          borderRadius: BorderRadius.circular(15), // Figma r=15
          border: Border.all(
            color: AppColors.socialButtonBorder,   // #000 @16%
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.cardTitle),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.socialButton),
          ],
        ),
      ),
    );
  }
}
