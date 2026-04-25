import 'package:flutter/material.dart';
import '../../core/localization/app_localization.dart';
import 'register_screen.dart';
import '../masyarakat/main_screen.dart';
import '../relawan/relawan_main_screen.dart';
import '../../core/models/user_model.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedMockRole = 'Masyarakat Umum';
  static const List<String> _mockRoles = [
    'Masyarakat Umum',
    'Relawan (Terverifikasi)',
    'Instansi Penyelamat',
    'Admin Sistem',
  ];

  void _login() {
    UserRole newRole = UserRole.masyarakat;
    String volStatus = 'none';

    if (_selectedMockRole == 'Relawan (Terverifikasi)') {
      newRole = UserRole.relawan;
      volStatus = 'approved';
    } else if (_selectedMockRole == 'Instansi Penyelamat') {
      newRole = UserRole.instansi;
    } else if (_selectedMockRole == 'Admin Sistem') {
      newRole = UserRole.admin;
    }
    
    final user = UserModel.currentUser.value;
    UserModel.currentUser.value = user.copyWith(
      role: newRole,
      volunteerStatus: volStatus,
      isAvailableForMission: newRole == UserRole.relawan ? true : false,
    );

    if (newRole == UserRole.instansi || newRole == UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedMockRole.tr(context)}: ${'Dasbor sedang dalam pengembangan'.tr(context)}')),
      );
      return;
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'lib/components/logo_siagakita.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Icon(Icons.shield, size: 60, color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Selamat Datang'.tr(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk untuk mengakses sistem pelaporan darurat dan jejaring relawan.'.tr(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              
              // Email
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
                ),
                child: TextField(
                  controller: _emailController,
                  style: TextStyle(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Email Anda'.tr(context),
                    hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.4)),
                    prefixIcon: Icon(Icons.email_outlined, color: colors.onSurface.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Kata Sandi'.tr(context),
                    hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.4)),
                    prefixIcon: Icon(Icons.lock_outline, color: colors.onSurface.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Mock Role Selector (Dev mode)
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMockRole,
                    isExpanded: true,
                    icon: Icon(Icons.developer_mode, color: primaryColor),
                    items: _mockRoles
                        .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text('${'Login sebagai'.tr(context)}: ${role.tr(context)}',
                                style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold, fontSize: 14))))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedMockRole = val!);
                    },
                  ),
                ),
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('Lupa sandi?'.tr(context), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: primaryColor.withValues(alpha: 0.5),
                ),
                child: Text('Masuk'.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun?'.tr(context), style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6))),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Text('Daftar di sini'.tr(context), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
