import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'guide_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import '../relawan/relawan_main_screen.dart';
import '../../core/models/user_model.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel>(
      valueListenable: UserModel.currentUser,
      builder: (context, user, child) {
        final isRelawan = user.volunteerStatus == 'approved' || user.role == UserRole.relawan;
        
        final List<Widget> screens = [
          const HomeScreen(),
          const GuideScreen(),
          if (isRelawan) const RelawanMainScreen(),
          const MapScreen(),
          const ProfileScreen(),
        ];

        final List<BottomNavigationBarItem> navItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            activeIcon: Icon(Icons.shield),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Panduan',
          ),
          if (isRelawan)
            const BottomNavigationBarItem(
              icon: Icon(Icons.radar_outlined),
              activeIcon: Icon(Icons.radar),
              label: 'Operasi',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ];

        // Mencegah error jika role berubah dan currentIndex di luar batas
        if (_currentIndex >= screens.length) {
          _currentIndex = 0;
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: navItems,
            ),
          ),
        );
      }
    );
  }
}
