import 'package:flutter/material.dart';
import 'profile_view.dart';
import 'shifts_history_view.dart';
import 'shift_request_view.dart';
import 'my_schedule_view.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 3; //افتراضياً يبدأ من شاشة حسابي (الم لف الشخصي) ت

  // قائمة الشاشات حسب الترتيب في الشريط السفلي
  final List<Widget> _pages = [
    const ShiftsHistoryView(), // الجدول والسجل (يحتوي داخله على التبديل بين الحالي والسابق)
    const ShiftRequestView(),  // طلب تبديل مناوبة
    const MyScheduleView(),    // جدولي والتعويض الشهري
    const ProfileView(),       // حسابي / الملف الشخصي
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, 
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color(0xFFE52E2E), 
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'الجدول',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz),
              label: 'طلب تبديل',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'جدولي',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}