import 'package:flutter/material.dart';
import '../../core/widgets/role_placeholder.dart';
import '../auth/login_screen.dart';

class RelawanMainScreen extends StatefulWidget {
  const RelawanMainScreen({super.key});

  @override
  State<RelawanMainScreen> createState() => _RelawanMainScreenState();
}

class _RelawanMainScreenState extends State<RelawanMainScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    PlaceholderTab(Icons.assignment_outlined, Icons.assignment, 'Tugas', 'Tugas Aktif', 'Lihat dan kelola penugasan lapangan Anda.', Colors.green),
    PlaceholderTab(Icons.map_outlined, Icons.map, 'Peta', 'Peta Sebaran', 'Pantau lokasi kejadian di peta real-time.', Colors.blue),
    PlaceholderTab(Icons.groups_outlined, Icons.groups, 'Koordinasi', 'Koordinasi Tim', 'Komunikasi dengan sesama relawan dan instansi.', Colors.orange),
    PlaceholderTab(Icons.person_outline, Icons.person, 'Profil', 'Profil Relawan', 'Data diri dan sertifikasi relawan Anda.', Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_currentIndex];
    return Scaffold(
      body: RolePlaceholderBody(
        role: 'Relawan',
        roleColor: Colors.green,
        tabName: tab.name,
        tabDescription: tab.description,
        tabIcon: tab.activeIcon,
        tabColor: tab.color,
        onLogout: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.green,
          onTap: (i) => setState(() => _currentIndex = i),
          items: _tabs.map((t) => BottomNavigationBarItem(
            icon: Icon(t.icon),
            activeIcon: Icon(t.activeIcon),
            label: t.label,
          )).toList(),
        ),
      ),
    );
  }
}
