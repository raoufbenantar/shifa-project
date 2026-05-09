import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shifa/homeScreen/role_selection_screen.dart';


// ─────────────────────────────────────────────
// WHY: main() is the single entry point Flutter
// calls when the app starts. We call
// WidgetsFlutterBinding.ensureInitialized()
// first so any plugin / platform channel that
// needs the engine to be ready (Firebase, etc.)
// can be safely initialised before runApp().
// ─────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait mode only –
  // medical apps rarely need landscape.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ShifaApp());
}

// ─────────────────────────────────────────────
// ShifaApp is a StatelessWidget because the
// top-level MaterialApp configuration never
// changes at runtime.
// ─────────────────────────────────────────────
class ShifaApp extends StatelessWidget {
  const ShifaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shifa',
      debugShowCheckedModeBanner: false,

      // ── Global theme ──────────────────────
      // We define all brand colours and text
      // styles here once so every widget in the
      // tree inherits them without repeating
      // hard-coded values.
      theme: ThemeData(
        useMaterial3: true,

        // Primary brand colour taken directly
        // from Figma: #3ECCAF
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3ECCAF),
          primary: const Color(0xFF3ECCAF),
        ),

        // Inter is the font used throughout the
        // Figma design.  Add the google_fonts
        // package and swap GoogleFonts.inter()
        // if you want automatic font loading.
        fontFamily: 'Inter',

        // Remove the default ripple/splash so
        // our custom card taps look clean.
        splashFactory: NoSplash.splashFactory,
      ),

      // The first screen the user sees is the
      // role-selection / welcome screen.
      home: const RoleSelectionScreen(),
    );
  }
}
