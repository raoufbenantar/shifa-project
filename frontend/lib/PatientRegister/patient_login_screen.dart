import 'package:flutter/material.dart';
import 'package:shifa/PatientRegister/patient_signup_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────
// PatientLoginScreen
//
// Figma layout (top → bottom):
//  1. Teal header  – back arrow · "Patient Login"
//                    · subtitle
//  2. White body   – "Phone Number" label
//                  – Phone field  (355×73, r=12)
//                  – "Password" label
//                  – Password field (same size)
//                  – "Sign in" button (331×61, r=21)
//                  – "or continue with" divider row
//                  – Google + Apple buttons (129×39, r=15)
//                  – "Don't have an account? Register"
//
// Backend mapping:
//   POST /auth/login  →  { phone, password, role:'patient' }
//   Response          →  { token, user_id, role_id }
//   Tables used       →  users · patient_profiles
// ─────────────────────────────────────────────

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  // ── Controllers ───────────────────────────
  // WHY TextEditingController?
  // We need to READ the field value on button
  // tap.  Controllers give us .text directly
  // without rebuilding the widget tree.
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Tracks whether the password is shown or
  // hidden so the eye-icon toggle works.
  bool _obscurePassword = true;

  // Tracks network call in progress to disable
  // the button and show a loading indicator.
  bool _isLoading = false;

  @override
  void dispose() {
    // WHY dispose controllers?
    // Forgetting this causes a memory leak –
    // the controller stays alive even after the
    // screen is removed from the tree.
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Sign-in handler ───────────────────────
  // Connects to the backend `users` table via
  // your REST API.  The phone number maps to
  // patient_profiles.phone_number and the
  // returned role_id must equal the 'patient'
  // row in the `roles` table.
  Future<void> _signIn() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: replace with real API call e.g.:
    // final response = await AuthService.login(
    //   phone: phone, password: password, role: 'patient');
    // if (response.success) Navigator.pushReplacement(…HomeScreen…);

    await Future.delayed(const Duration(seconds: 1)); // simulate network
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // WHY resizeToAvoidBottomInset: true (default)?
      // When the keyboard opens the white body
      // scrolls up so the focused field is always
      // visible.  We wrap the body in
      // SingleChildScrollView for the same reason.
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ════════════════════════════════
          // 1. TEAL HEADER
          // ════════════════════════════════
          Container(
            width: double.infinity,
            // Figma header is shorter than the
            // welcome screen – roughly 28% of
            // screen height fits the back arrow
            // + title + subtitle comfortably.
            height: MediaQuery.of(context).size.height * 0.28,
            color: AppColors.primary, // #3ECCAF
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Back arrow ────────
                    // Figma: circle outline icon, white
                    // WHY GestureDetector not IconButton?
                    // IconButton adds 48px tap target
                    // padding that shifts the icon away
                    // from the Figma position.
                    // GestureDetector lets us control
                    // the exact size ourselves.
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

                    // "Patient Login" · Inter Bold 26px #FFFFFF
                    Text('Patient Login', style: AppTextStyles.loginTitle),
                    const SizedBox(height: 8),

                    // Subtitle · Inter Regular 14px #FFFFFF
                    Text(
                      'Sign in to access your health portal',
                      style: AppTextStyles.loginSubtitle,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // ════════════════════════════════
          // 2. WHITE BODY
          // ════════════════════════════════
          Expanded(
            child: SingleChildScrollView(
              // WHY horizontal 20px padding?
              // Figma shows Left=20px for the
              // phone field (355px wide on 390px
              // canvas → 390-355=35px split as
              // ~17-18px each side, we use 20px
              // which is the standard safe margin).
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  // ── Phone Number field ───
                  // Figma Frame 4: 355×73, Left=20
                  // Label: Inter Regular 14px #000000
                  Text('Phone Number', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _phoneController,
                    hintText: '+213 XX XXX XXXX',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  // ── Password field ───────
                  Text('Password', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _passwordController,
                    hintText: 'Enter password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    // Eye-icon suffix to toggle visibility
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
                  ),

                  const SizedBox(height: 32),

                  // ── Sign in button ───────
                  // Figma Rectangle 9:
                  //   width 331 · height 61
                  //   radius 21 · color #3ECCAF
                  // WHY SizedBox wrapping the button?
                  // ElevatedButton respects the
                  // constraints given by its parent.
                  // SizedBox forces exact Figma width
                  // and height without overriding the
                  // button's internal padding logic.
                  SizedBox(
                    width: double.infinity, // fills horizontal padding
                    height: 61, // Figma: 61px height
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // #3ECCAF
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(21), // Figma: radius 21
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Sign in', style: AppTextStyles.signInButton),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── "or continue with" ───
                  // Thin lines on each side of text
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(
                              color: AppColors.divider, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or continue with',
                            style: AppTextStyles.orContinue),
                      ),
                      const Expanded(
                          child: Divider(
                              color: AppColors.divider, thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Social buttons row ───
                  // Figma Rectangle 10:
                  //   width 129 · height 39
                  //   radius 15 · bg #F9FAFB
                  //   border 1px #000000 @ 16%
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        label: 'Google',
                        // Google "G" coloured logo via text trick;
                        // replace with Image.asset once you add the
                        // SVG to assets/images/google.svg
                        icon: Icons.g_mobiledata,
                        onTap: () {
                          // TODO: Google sign-in
                        },
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        label: 'Apple',
                        icon: Icons.apple,
                        onTap: () {
                          // TODO: Apple sign-in
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Register prompt ──────
                  // Figma: Inter Light 300 · 16px
                  // "Don't have an account?" grey
                  // "Register" in teal #3ECCAF
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.registerPrompt,
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          WidgetSpan(
                            // WHY WidgetSpan with GestureDetector?
                            // TextSpan's recognizer needs a
                            // TapGestureRecognizer object that must
                            // be manually disposed. WidgetSpan with
                            // GestureDetector is simpler and avoids
                            // the memory-leak risk.
                            child: GestureDetector(
                              onTap: () {
                                // WHY push (not pushReplacement)?
                                // The user might go back from signup
                                // to login, so we keep login on stack.
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const PatientSignupScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Register',
                                style: AppTextStyles.registerLink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _InputField – reusable text field widget
//
// WHY extract this?
// Both the phone and password fields share the
// same border, radius, icon style and padding.
// One widget handles both; differences are
// passed as constructor parameters.
// ─────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Figma Frame 4: height 73px total
      // (label 17px + gap 8px + field ~48px ≈ 73)
      // We size the field itself to 52px which
      // looks right with internal vertical padding.
      height: 52,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AppTextStyles.fieldHint.copyWith(color: AppColors.cardTitle),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.fieldHint,

          // Teal phone / lock icon on the left
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.primary, // #3ECCAF
            size: 20,
          ),

          suffixIcon: suffixIcon,

          // ── Border styling ─────────────
          // Figma fields have a subtle rounded
          // border (visible as a thin outline)
          // with a very light background fill.
          filled: true,
          fillColor: AppColors.background,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.divider, // light grey when idle
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary, // teal when focused – Figma
              width: 1.5,
            ),
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _SocialButton – Google / Apple button
//
// Figma Rectangle 10:
//   width 129 · height 39 · radius 15
//   bg #F9FAFB · border 1px #000000 @ 16%
// ─────────────────────────────────────────────
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
        width: 129, // Figma exact width
        height: 39,  // Figma exact height
        decoration: BoxDecoration(
          color: AppColors.socialButtonBg,       // #F9FAFB
          borderRadius: BorderRadius.circular(15), // Figma radius 15
          border: Border.all(
            color: AppColors.socialButtonBorder,  // #000000 @ 16%
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
