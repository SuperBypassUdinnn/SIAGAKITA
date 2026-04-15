import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedCategoryIndex = -1;
  int _urgencyLevel = 1; // 0 = Ringan, 1 = Sedang, 2 = Kritis

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Kebakaran', 'icon': Icons.local_fire_department, 'color': Colors.orange},
    {'title': 'Kecelakaan', 'icon': Icons.car_crash, 'color': Colors.red},
    {'title': 'Bencana Alam', 'icon': Icons.water_damage, 'color': Colors.blue},
    {'title': 'Kriminalitas', 'icon': Icons.warning_rounded, 'color': Colors.purple},
    {'title': 'Medis', 'icon': Icons.medical_services, 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Buat Laporan', style: TextStyle(color: colors.onBackground, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onBackground),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Lokasi (Mini Map Simulation)
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    // Simulated Map Image/Box
                    Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D1B3E),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Stack(
                        children: [
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                            itemCount: 40,
                            itemBuilder: (ctx, i) => Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.5))),
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.location_on, color: primaryColor, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.gps_fixed, color: Colors.green, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Lokasi Otomatis Ditemukan', style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('Jl. Cut Nyak Dhien, Lhoknga, Aceh', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                              ],
                            ),
                          ),
                          Icon(Icons.edit_location_alt, color: primaryColor, size: 20),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Kategori Darurat
              Text('Kategori Darurat', style: TextStyle(color: colors.onBackground, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? primaryColor : colors.onSurface.withValues(alpha: 0.1)),
                          boxShadow: isDark ? [] : [if (isSelected) BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8)],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat['icon'], color: isSelected ? Colors.white : cat['color'], size: 32),
                            const SizedBox(height: 8),
                            Text(
                              cat['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : colors.onSurface,
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 3. Media
              Text('Lampiran Foto & Audio', style: TextStyle(color: colors.onBackground, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.onSurface.withValues(alpha: 0.2), style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 32, color: colors.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(height: 8),
                          Text('Ketuk ambil foto', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.onSurface.withValues(alpha: 0.2), style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.mic, size: 24, color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          Text('Tahan rekaman suara', textAlign: TextAlign.center, style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Deskripsi
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
                ),
                child: TextField(
                  maxLines: 3,
                  style: TextStyle(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Ketik deksripsi tambahan jika ada...',
                    hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.4)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Urgency
              Text('Tingkat Urgensi', style: TextStyle(color: colors.onBackground, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildUrgencyPill(0, 'Ringan', Colors.green, colors),
                  const SizedBox(width: 12),
                  _buildUrgencyPill(1, 'Sedang', Colors.orange, colors),
                  const SizedBox(width: 12),
                  _buildUrgencyPill(2, 'Kritis', Colors.red, colors),
                ],
              ),
              
              const SizedBox(height: 48),

              // Kirim Laporan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan Berhasil Dikirim!'), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Kirim Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _urgencyLevel == 2 ? Colors.red : primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyPill(int level, String text, Color targetColor, ColorScheme colors) {
    final isSelected = _urgencyLevel == level;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _urgencyLevel = level),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? targetColor : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? targetColor : colors.onSurface.withValues(alpha: 0.1)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : colors.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
