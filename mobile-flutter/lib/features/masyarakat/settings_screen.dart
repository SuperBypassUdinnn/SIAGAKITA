import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock states for settings toggles
  bool _pushNotifications = true;
  bool _smsAlerts = false;
  bool _locationTracking = true;
  bool _darkMode = true;
  String _language = 'Bahasa Indonesia';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black87;
    final cardColor = isDark ? colors.surfaceContainerHighest : Colors.white;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold, color: primaryTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. Notifikasi & Lansiran
          _buildSectionHeader('NOTIFIKASI & LANSIRAN', colors),
          Card(
            color: cardColor,
            elevation: isDark ? 0 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isDark ? BorderSide(color: Colors.grey.withValues(alpha: 0.2)) : BorderSide.none,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Notifikasi Push (Aplikasi)', style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600)),
                  subtitle: Text('Peringatan darurat via aplikasi', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                  activeColor: Colors.orange,
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.shade200),
                SwitchListTile(
                  title: Text('Lansiran SMS', style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600)),
                  subtitle: Text('Kirim pesan SMS jika tidak ada koneksi internet', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                  activeColor: Colors.orange,
                  value: _smsAlerts,
                  onChanged: (val) => setState(() => _smsAlerts = val),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // 2. Privasi & Lokasi
          _buildSectionHeader('PRIVASI & LOKASI', colors),
          Card(
            color: cardColor,
            elevation: isDark ? 0 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isDark ? BorderSide(color: Colors.grey.withValues(alpha: 0.2)) : BorderSide.none,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Akses Lokasi Latar Belakang', style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600)),
                  subtitle: Text('Sangat disarankan untuk evakuasi cepat', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                  activeColor: Colors.orange,
                  value: _locationTracking,
                  onChanged: (val) => setState(() => _locationTracking = val),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.shade200),
                ListTile(
                  title: Text('Izin Akses Kamera & Galeri', style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // 3. Tampilan & Aksesibilitas
          _buildSectionHeader('TAMPILAN & AKSESIBILITAS', colors),
          Card(
            color: cardColor,
            elevation: isDark ? 0 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isDark ? BorderSide(color: Colors.grey.withValues(alpha: 0.2)) : BorderSide.none,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Mode Gelap (Dark Mode)', style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600)),
                  activeColor: Colors.orange,
                  value: _darkMode,
                  onChanged: (val) {
                    setState(() => _darkMode = val);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tema dikendalikan oleh sistem saat ini.')));
                  },
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.shade200),
                ListTile(
                  title: Text('Bahasa', style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_language, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // 4. Akun & Keamanan
          _buildSectionHeader('AKUN & KEAMANAN', colors),
          Card(
            color: cardColor,
            elevation: isDark ? 0 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isDark ? BorderSide(color: Colors.grey.withValues(alpha: 0.2)) : BorderSide.none,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.grey),
                  title: Text('Ubah Kata Sandi', style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {},
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.shade200),
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: Colors.grey),
                  title: Text('Autentikasi Dua Langkah (2FA)', style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600)),
                  trailing: const Text('Nonaktif', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  onTap: () {},
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.shade200),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Hapus Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: cardColor,
                        title: const Text('Hapus Akun?'),
                        content: const Text('Tindakan ini tidak dapat dibatalkan. Seluruh riwayat donasi darah, poin relawan, dan rekam medis darurat akan dihapus permanen.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            child: const Text('Hapus Permanen'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: colors.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          fontSize: 12,
        ),
      ),
    );
  }
}
