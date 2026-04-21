import 'package:flutter/material.dart';
import '../../core/widgets/role_placeholder.dart';
import '../auth/login_screen.dart';

class InstansiMainScreen extends StatefulWidget {
  const InstansiMainScreen({super.key});

  @override
  State<InstansiMainScreen> createState() => _InstansiMainScreenState();
}

class _InstansiMainScreenState extends State<InstansiMainScreen> {
  int _currentIndex = 0;

  static const _roleColor = Color(0xFFFF7418);

  static const _tabs = [
    PlaceholderTab(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', 'Dashboard', 'Ringkasan statistik kejadian aktif di wilayah Anda.', _roleColor),
    PlaceholderTab(Icons.inbox_outlined, Icons.inbox, 'Laporan', 'Laporan Masuk', 'Kelola laporan darurat yang masuk dari masyarakat.', Colors.red),
    PlaceholderTab(Icons.people_outline, Icons.people, 'Tim', 'Tim Lapangan', 'Kelola penugasan tim dan sumber daya lapangan.', Colors.blue),
    PlaceholderTab(Icons.account_balance_outlined, Icons.account_balance, 'Profil', 'Profil Instansi', 'Informasi dan pengaturan instansi Anda.', Colors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_currentIndex];
    return Scaffold(
      body: RolePlaceholderBody(
        role: 'Instansi Penyelamat',
        roleColor: _roleColor,
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
          selectedItemColor: _roleColor,
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
