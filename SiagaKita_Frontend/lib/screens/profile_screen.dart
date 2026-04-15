import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profil Pengguna', style: TextStyle(color: colors.onBackground, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // User Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: Colors.blue[900]?.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: colors.onSurface.withValues(alpha: 0.1))),
                          child: Icon(Icons.person, color: colors.onSurface.withValues(alpha: 0.5), size: 32),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: colors.surface, width: 2)),
                            child: const Icon(Icons.verified_user, color: Colors.white, size: 10),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Budi Santoso', style: TextStyle(color: colors.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('ID: SK-2983-4412', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 12, fontFamily: 'monospace')),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Biometric Ledger
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                  boxShadow: isDark ? [] : [BoxShadow(color: colors.primary.withValues(alpha: 0.1), blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.fingerprint, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('BIOMETRIC SAFETY LEDGER', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ],
                        ),
                        Icon(Icons.verified_user, color: colors.onSurface.withValues(alpha: 0.4), size: 18),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildInfoBox('Golongan\nDarah', 'O Positif', context)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInfoBox('Berat / Tinggi', '70kg / 175\ncm', context)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildListRow(Icons.error_outline, 'ALERGI UTAMA', 'Penisilin, Kacang', Colors.orange, context),
                    const SizedBox(height: 16),
                    _buildListRow(Icons.favorite_border, 'RIWAYAT MEDIS', 'Asma Ringan', Colors.blue, context),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Emergency Contact
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text('Kontak Darurat', style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(color: Colors.blue[900]?.withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.person, color: Colors.blueAccent, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Siti Aminah (Istri)', style: TextStyle(color: colors.onSurface, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('0812-3456-7890', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6), fontSize: 10)),
                                ],
                              )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.phone, color: Colors.green, size: 16),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dukungan Siagakita
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dukungan SiagaKita', style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.orange, size: 16),
                        const SizedBox(width: 12),
                        Text('bantuan@siagakita.id', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.orange, size: 16),
                        const SizedBox(width: 12),
                        Text('Pusat Panggilan: 112 (Darurat)', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String val, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(val, textAlign: TextAlign.center, style: TextStyle(color: colors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildListRow(IconData icon, String label, String val, Color iconColor, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(color: colors.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }
}
