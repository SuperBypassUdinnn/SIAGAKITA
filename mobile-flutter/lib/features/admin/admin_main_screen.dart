import 'package:flutter/material.dart';
import '../../core/widgets/role_placeholder.dart';
import '../auth/login_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  static const _roleColor = Color(0xFFA855F7);

  static const _tabs = [
    PlaceholderTab(Icons.bar_chart_outlined, Icons.bar_chart, 'Statistik', 'Statistik Sistem', 'Pantau data dan tren kejadian seluruh wilayah.', _roleColor),
    PlaceholderTab(Icons.manage_accounts_outlined, Icons.manage_accounts, 'User', 'Kelola Pengguna', 'Verifikasi, aktifkan, atau nonaktifkan akun pengguna.', Colors.blue),
    PlaceholderTab(Icons.folder_open_outlined, Icons.folder_open, 'Laporan', 'Kelola Laporan', 'Tinjau dan moderasi semua laporan masuk.', Colors.orange),
    PlaceholderTab(Icons.settings_outlined, Icons.settings, 'Setting', 'Pengaturan Sistem', 'Konfigurasi sistem dan parameter aplikasi.', Colors.grey),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_currentIndex];
    return Scaffold(
      body: RolePlaceholderBody(
        role: 'Administrator',
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
