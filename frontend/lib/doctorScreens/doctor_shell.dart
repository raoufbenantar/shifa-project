import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'doctorDashboard/doctor_dashboard_screen.dart';
import 'scheduleScreen/schedule_screen.dart';
import 'messagesScreen/messages_screen.dart';
import 'notificationsScreen/notifications_screen.dart';
import 'reviewsScreen/reviews_screen.dart';

/// Root shell for the doctor section. Holds the persistent
/// BottomNavigationBar and swaps the body based on the active tab.
class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DoctorDashboardScreen(),
    ScheduleScreen(),
    MessagesScreen(),
    NotificationsScreen(),
    ReviewsScreen(),
  ];

  static const _items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_outlined),
      activeIcon: Icon(Icons.calendar_month_rounded),
      label: 'Schedule',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline_rounded),
      activeIcon: Icon(Icons.chat_bubble_rounded),
      label: 'Messages',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_outlined),
      activeIcon: Icon(Icons.notifications_rounded),
      label: 'Alerts',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.star_outline_rounded),
      activeIcon: Icon(Icons.star_rounded),
      label: 'Reviews',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: _items,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF9CA3AF),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
              fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(
              fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 11),
        ),
      ),
    );
  }
}
