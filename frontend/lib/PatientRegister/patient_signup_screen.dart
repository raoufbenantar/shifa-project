import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shifa/PatientRegister/register_patient_usecase.dart';
import 'package:shifa/PatientRegister/signup_bloc.dart';
import 'package:shifa/PatientRegister/signup_entity.dart';
import 'package:shifa/PatientRegister/signup_event.dart';
import 'package:shifa/PatientRegister/signup_remote_datasource.dart';
import 'package:shifa/PatientRegister/signup_repository_impl.dart';
import 'package:shifa/PatientRegister/signup_state.dart';

import '../../../../../theme/app_colors.dart';
import '../theme/app_text_styles.dart';


// ─────────────────────────────────────────────────────────────
// PatientSignupScreen
//
// Figma screen: "Personal Information – Step 1 of 2"
//
// Layout extracted from Figma screenshots:
//   Header : width 390 · height 187.57 · bg #3ECCAF
//            back arrow (circle) · "Personal Information" Bold 26px
//            "Step 1 of 2" Regular 14px – both white
//   Body   : white · 6 input fields · "create account" button
//
// Field list (top → bottom):
//   1. Full name       – person icon   – text
//   2. Phone Number    – phone icon    – phone keyboard (+213 prefix)
//   3. Email Address   – email icon    – email keyboard
//   4. Date of birth   – calendar icon – date picker on tap
//   5. National ID     – card icon     – text
//   6. Password        – lock icon     – obscured + eye toggle
//
// Button: "create account" – width 331 · height 61 · radius 21 · #3ECCAF
//         text: Inter Bold 26px white
//
// Database alignment (FINAL_DIAGRAM):
//   users            → email, password_hash, role_id='patient'
//   patient_profiles → full_name, phone_number, date_of_birth
// ─────────────────────────────────────────────────────────────

class PatientSignupScreen extends StatelessWidget {
  const PatientSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Dependency wiring ─────────────────────────────────
    // WHY wire dependencies in the widget tree?
    // We use BlocProvider to create the BLoC and inject its
    // dependencies here.  This keeps main.dart clean and
    // scopes the BLoC's lifetime to this screen only –
    // it is automatically closed when the screen is popped.
    return BlocProvider(
      create: (_) => SignupBloc(
        RegisterPatientUseCase(
          SignupRepositoryImpl(
            SignupRemoteDataSourceImpl(),
          ),
        ),
      ),
      child: const _PatientSignupView(),
    );
  }
}

// ── Private view widget ──────────────────────────────────────
// WHY split into PatientSignupScreen + _PatientSignupView?
// PatientSignupScreen owns dependency wiring (BlocProvider).
// _PatientSignupView owns UI.  Separating them means we can
// test the UI widget independently by injecting a mock BLoC.
// ─────────────────────────────────────────────────────────────
class _PatientSignupView extends StatefulWidget {
  const _PatientSignupView();

  @override
  State<_PatientSignupView> createState() => _PatientSignupViewState();
}

class _PatientSignupViewState extends State<_PatientSignupView> {
  // ── Form key ──────────────────────────────────────────────
  // WHY GlobalKey<FormState>?
  // It lets us call _formKey.currentState!.validate() on submit
  // to trigger every field's validator at once, without
  // managing individual error-string variables.
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────
  final _fullNameController    = TextEditingController();
  final _phoneController       = TextEditingController();
  final _emailController       = TextEditingController();
  final _dobController         = TextEditingController(); // display string
  final _nationalIdController  = TextEditingController();
  final _passwordController    = TextEditingController();

  // Stores the actual DateTime so we can pass it to the Entity.
  DateTime? _selectedDob;

  // Password visibility toggle state.
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks.
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Date picker ───────────────────────────────────────────
  // WHY a dedicated method?
  // showDatePicker is async; keeping it separate from build()
  // keeps the build method clean and readable.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25), // reasonable default age
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 1),     // must be at least 1 year old
      builder: (context, child) {
        // Tint the date picker to match the brand colour.
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        // Format as DD/MM/YYYY for display in the field.
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  // ── Submit handler ────────────────────────────────────────
  // Called when "create account" is tapped.
  // Validates the form FIRST, then dispatches the BLoC event.
  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    // Build the Domain Entity from form values.
    // WHY build the Entity here and not in the BLoC?
    // The screen owns the TextEditingControllers; the BLoC
    // must not reach into widgets.  The screen assembles the
    // data and hands a clean Entity to the BLoC.
    final entity = SignupEntity(
      fullName:    _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email:       _emailController.text.trim(),
      dateOfBirth: _selectedDob!,
      nationalId:  _nationalIdController.text.trim(),
      password:    _passwordController.text,
    );

    context.read<SignupBloc>().add(SignupSubmitted(entity));
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── BLoC listener ───────────────────────────────────
      // WHY BlocConsumer instead of BlocBuilder?
      // BlocConsumer has both a `listener` (for one-time side
      // effects like navigation and SnackBars) AND a `builder`
      // (for rebuilding the UI).
      // BlocBuilder alone cannot trigger navigation safely.
      body: BlocConsumer<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: AppColors.primary,
              ),
            );
            // TODO: Navigator.pushReplacement → PatientLoginScreen
            Navigator.pop(context);
          }
          if (state is SignupFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SignupLoading;

          return Column(
            children: [
              // ════════════════════════════════════════
              // 1. TEAL HEADER
              // Figma Group 3: width 390 · height 187.57
              // ════════════════════════════════════════
              Container(
                width: double.infinity,
                height: 187.57, // Figma exact value
                color: AppColors.primary, // #3ECCAF
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // ── Back arrow ──────────────
                        // Same style as PatientLoginScreen:
                        // circle border + arrow_back icon
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

                        // "Personal Information"
                        // Figma: Inter Bold 26px #FFFFFF
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                            color: AppColors.white,
                            height: 1.0,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // "Step 1 of 2"
                        // Figma: Inter Regular 14px #FFFFFF
                        const Text(
                          'Step 1 of 2',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColors.white,
                            height: 1.0,
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // ════════════════════════════════════════
              // 2. WHITE BODY – scrollable form
              // ════════════════════════════════════════
              Expanded(
                child: SingleChildScrollView(
                  // WHY SingleChildScrollView + Form?
                  // Form wraps all fields so _formKey.validate()
                  // triggers every validator in one call.
                  // SingleChildScrollView prevents overflow
                  // when the keyboard is open.
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // 1. Full name
                        _buildLabel('Full name'),
                        _buildInputField(
                          controller: _fullNameController,
                          hintText: '',
                          prefixIcon: Icons.person_outline,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Full name is required'
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // 2. Phone Number
                        _buildLabel('Phone Number'),
                        _buildInputField(
                          controller: _phoneController,
                          hintText: '+213 XX XXX XXXX',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            // Algerian format: +213 followed by 9 digits
                            final clean = v.replaceAll(' ', '');
                            if (!RegExp(r'^\+213\d{9}$').hasMatch(clean)) {
                              return 'Enter a valid Algerian number (+213XXXXXXXXX)';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // 3. Email Address
                        _buildLabel('Email Address'),
                        _buildInputField(
                          controller: _emailController,
                          hintText: '',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(v.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // 4. Date of birth – read-only, opens date picker
                        _buildLabel('Date of birth'),
                        _buildInputField(
                          controller: _dobController,
                          hintText: '',
                          prefixIcon: Icons.calendar_month_outlined,
                          // WHY readOnly + onTap?
                          // We don't want the keyboard to open for
                          // a date field.  readOnly blocks the
                          // keyboard; onTap opens our native date
                          // picker instead.
                          readOnly: true,
                          onTap: _pickDate,
                          validator: (_) => _selectedDob == null
                              ? 'Date of birth is required'
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // 5. National ID
                        _buildLabel('National ID'),
                        _buildInputField(
                          controller: _nationalIdController,
                          hintText: '',
                          prefixIcon: Icons.credit_card_outlined,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'National ID is required'
                                  : null,
                        ),

                        const SizedBox(height: 16),

                        // 6. Password
                        _buildLabel('Password'),
                        _buildInputField(
                          controller: _passwordController,
                          hintText: '',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
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
                            if (v.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // ── "create account" button ──────
                        // Figma Rectangle 12:
                        //   width 331 · height 61 · radius 21 · #3ECCAF
                        // Text: Inter Bold 26px #FFFFFF
                        Center(
                          child: SizedBox(
                            width: 331,  // Figma exact width
                            height: 61,  // Figma exact height
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor:
                                    AppColors.primary.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(21),
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
                                      'create account',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700, // Bold
                                        fontSize: 26, // Figma: 26px
                                        color: AppColors.white,
                                        height: 1.0,
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
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // WHY private helper methods instead of inline widgets?
  // Each field needs the same label + field pair structure.
  // Extracting to methods keeps build() readable and avoids
  // copy-pasting the same Container decoration 6 times.
  // ─────────────────────────────────────────────────────────

  /// Builds the grey field label above each input.
  /// Figma: Inter Regular 400 · 14px · #000000 · Left=33px
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.fieldLabel, // Inter 400 14px #000000
      ),
    );
  }

  /// Builds a single input field matching Figma Frame 8:
  ///   width 355 · height 73 · Left=20px
  ///   bg #F9FAFB · border #E5E7EB · radius 12
  ///   prefix icon teal · hint text grey
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      // Figma Frame 8 total height (label included) = 73px.
      // The label is ~17px + 8px gap, leaving ~48px for the
      // field itself.  We use 52px for comfortable touch target.
      height: 52,
      child: TextFormField(
        // WHY TextFormField instead of TextField?
        // TextFormField integrates with Form/GlobalKey so that
        // _formKey.currentState!.validate() calls every
        // field's validator automatically on submit.
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.cardTitle,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB), // Figma field bg
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.primary, // teal icon #3ECCAF
            size: 20,
          ),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB), // Figma border colour
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
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          // Show validation errors below the field
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
