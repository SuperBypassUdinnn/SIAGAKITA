import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../auth/login_screen.dart';

class RelawanMainScreen extends StatefulWidget {
  const RelawanMainScreen({super.key});

  @override
  State<RelawanMainScreen> createState() => _RelawanMainScreenState();
}

class _RelawanMainScreenState extends State<RelawanMainScreen> {
  // Toggle availability
  void _toggleAvailability(bool value) {
    final user = UserModel.currentUser.value;
    UserModel.currentUser.value = user.copyWith(isAvailableForMission: value);
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildGridMenu(String title, IconData icon, Color badgeColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menu $title Segera Hadir')));
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.shade300),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: badgeColor.withValues(alpha: 0.2),
              radius: 28,
              child: Icon(icon, color: badgeColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 12,
                color: isDark ? Colors.white : const Color(0xFF0D1B3E)
              )
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Paksa UI nuansa gelap pekat jika memungkinkan (Tactical Mode)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield, color: Colors.orange),
            const SizedBox(width: 8),
            Text('SiagaKita Tactical', style: TextStyle(fontWeight: FontWeight.w900, color: primaryTextColor)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.red,
            tooltip: 'Keluar',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: ValueListenableBuilder<UserModel>(
        valueListenable: UserModel.currentUser,
        builder: (context, user, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER REPUtTASI
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Komando Operasi', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text('Halo, ${user.name.split(" ")[0]}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryTextColor)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                          child: Text(user.specialization ?? 'General', style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      child: const Icon(Icons.person, size: 36, color: Colors.grey),
                    )
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 2. TOGGLE STATUS KETERSEDIAAN
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: user.isAvailableForMission ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: user.isAvailableForMission ? Colors.green : Colors.red, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            user.isAvailableForMission ? Icons.radar : Icons.do_not_disturb_on,
                            color: user.isAvailableForMission ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            user.isAvailableForMission ? 'ON DUTY (Siap Tugas)' : 'OFF DUTY (Istirahat)',
                            style: TextStyle(
                              color: user.isAvailableForMission ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                      Switch(
                        value: user.isAvailableForMission,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        onChanged: _toggleAvailability,
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                // 3. STATISTIK
                Row(
                  children: [
                    _buildStatCard('Poin Misi', '${user.volunteerPoints}', Icons.stars, Colors.orange),
                    const SizedBox(width: 16),
                    _buildStatCard('Level', user.volunteerLevel, Icons.military_tech, Colors.blue),
                  ],
                ),

                const SizedBox(height: 32),

                // 4. RADAR MISI DARURAT
                Text('RADAR INSIDEN', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 12),
                user.isAvailableForMission 
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4))
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.warning, color: Colors.red, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text('PANGGILAN DARURAT!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Kecelakaan lalu lintas ganda, butuh evakuasi medis segera.', style: TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            const Text('1.2 KM (Simpang Lima)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const Spacer(),
                            const Icon(Icons.timer, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            const Text('Barusan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red.shade900,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengalihkan ke Navigasi Misi...')));
                            },
                            child: const Text('TERIMA MISI INI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.gpp_maybe, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('Radar Misi Nonaktif', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Hidupkan ON DUTY untuk melihat panggilan darurat di sekitar Anda.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // 5. FITUR PENUNJANG
                Text('KOORDINASI & ALAT', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildGridMenu('Live Chat Posko', Icons.headset_mic, Colors.blue),
                    _buildGridMenu('Panduan Medis', Icons.health_and_safety, Colors.red),
                    _buildGridMenu('Relawan Aktif', Icons.group, Colors.purple),
                    _buildGridMenu('Riwayat Misi', Icons.history, Colors.orange),
                  ],
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          );
        }
      ),
    );
  }
}
