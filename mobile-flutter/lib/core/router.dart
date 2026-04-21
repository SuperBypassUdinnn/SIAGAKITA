import 'package:flutter/material.dart';
import 'models/user_model.dart';
import '../features/masyarakat/main_screen.dart';
import '../features/relawan/relawan_main_screen.dart';
import '../features/instansi/instansi_main_screen.dart';
import '../features/admin/admin_main_screen.dart';

/// Router utama SiagaKita.
/// Mengembalikan home screen yang sesuai berdasarkan role pengguna.
/// 
/// Cara penggunaan setelah login berhasil:
/// ```dart
/// final user = UserModel(id: '1', name: 'Budi', email: '...', role: UserRole.relawan);
/// Navigator.pushReplacement(context, MaterialPageRoute(
///   builder: (_) => AppRouter.getHomeByRole(user.role),
/// ));
/// ```
class AppRouter {
  AppRouter._(); // Prevent instantiation

  /// Kembalikan widget home sesuai role
  static Widget getHomeByRole(UserRole role) {
    switch (role) {
      case UserRole.masyarakat:
        return const MainScreen();
      case UserRole.relawan:
        return const RelawanMainScreen();
      case UserRole.instansi:
        return const InstansiMainScreen();
      case UserRole.admin:
        return const AdminMainScreen();
    }
  }

  /// Navigasi ke home screen berdasarkan role (hapus semua history)
  static void navigateToHome(BuildContext context, UserRole role) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => getHomeByRole(role)),
      (route) => false,
    );
  }
}
