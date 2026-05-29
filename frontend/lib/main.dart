import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shifa/homeScreen/role_selection_screen.dart';
import 'core/services/push_notification_service.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize push notification service early.
  // It gracefully handles missing Firebase configuration.
  PushNotificationService.instance.initialize();

  // Lock the app to portrait mode only –
  // medical apps rarely need landscape.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ShifaApp());
}


class ShifaApp extends StatelessWidget {
  const ShifaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shifa',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3ECCAF),
          primary: const Color(0xFF3ECCAF),
        ),

        fontFamily: 'Inter',

        splashFactory: NoSplash.splashFactory,
      ),

      home: const RoleSelectionScreen(),
    );
  }
}
