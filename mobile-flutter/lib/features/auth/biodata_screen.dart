import 'package:flutter/material.dart';
import 'login_screen.dart';

class BiodataScreen extends StatefulWidget {
  const BiodataScreen({super.key});

  @override
  State<BiodataScreen> createState() => _BiodataScreenState();
}

class _BiodataScreenState extends State<BiodataScreen> {
  final _bloodTypeController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark 
              ? const ColorScheme.dark(primary: Colors.orange, onPrimary: Colors.white, surface: Color(0xFF162A5A), onSurface: Colors.white)
              : const ColorScheme.light(primary: Colors.orange, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  void _submitBiodata() {
    // Simulasi simpan biodata dan masuk ke halaman login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text('Lengkapi Biodata', style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Langkah Terakhir!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Data kesehatan ini sangat penting untuk penanganan medis darurat yang tepat sasaran.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Fisik & Kesehatan
              Text('Fisik & Kesehatan', style: TextStyle(color: colors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Data ini mempermudah tim penolong mengetahui karakteristik fisik Anda.', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 12)),
              const SizedBox(height: 16),
              _buildDateField(_birthDateController, 'Tanggal Lahir (DD-MM-YYYY)', Icons.calendar_today, colors),
              _buildDropdownField(_bloodTypeController, 'Gol. Darah', Icons.bloodtype, colors),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_weightController, 'Berat Badan (kg)', Icons.monitor_weight_outlined, colors, inputType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(_heightController, 'Tinggi Badan (cm)', Icons.height, colors, inputType: TextInputType.number),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Riwayat Medis & Alergi
              Text('Riwayat Penyakit & Alergi', style: TextStyle(color: colors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Kosongkan jika tidak ada. Data ini krusial untuk menghindari pantangan obat darurat.', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 12)),
              const SizedBox(height: 16),
              _buildTextField(_medicalHistoryController, 'Riwayat Medis (Misal: Asma, Hipertensi)', Icons.favorite_border, colors),
              _buildTextField(_allergiesController, 'Alergi Utama (Misal: Kacang, Penisilin)', Icons.warning_amber_rounded, colors),
              const SizedBox(height: 8),

              // Alamat Lengkap
              Text('Alamat Tempat Tinggal', style: TextStyle(color: colors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Sebagai acuan domisili terdekat jika evakuasi diperlukan.', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 12)),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
                ),
                child: TextField(
                  controller: _addressController,
                  maxLines: 3,
                  style: TextStyle(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Alamat lengkap sesuai domisili...',
                    hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.4)),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.location_on_outlined, color: colors.onSurface.withValues(alpha: 0.5)),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              // Kontak Darurat
              Text('Kontak Darurat (Wali/Keluarga)', style: TextStyle(color: colors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Orang yang akan dihubungi jika Anda dalam bahaya.', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 12)),
              const SizedBox(height: 16),
              _buildTextField(_emergencyContactNameController, 'Nama Kontak Darurat', Icons.person_outline, colors),
              _buildTextField(_emergencyContactPhoneController, 'Nomor Telepon Darurat', Icons.phone, colors, inputType: TextInputType.phone),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitBiodata,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: primaryColor.withValues(alpha: 0.3),
                ),
                child: const Text('Simpan & Selesai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String hint, IconData icon, ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(context),
        style: TextStyle(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.4), fontSize: 12),
          prefixIcon: Icon(icon, color: colors.onSurface.withValues(alpha: 0.5), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField(TextEditingController controller, String hint, IconData icon, ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.text.isNotEmpty ? controller.text : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.4), fontSize: 12),
          prefixIcon: Icon(icon, color: colors.onSurface.withValues(alpha: 0.5), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        dropdownColor: colors.surface,
        style: TextStyle(color: colors.onSurface, fontSize: 14),
        items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Belum Tahu']
            .map((val) => DropdownMenuItem(value: val, child: Text(val)))
            .toList(),
        onChanged: (val) {
          if (val != null) controller.text = val;
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, ColorScheme colors, {TextInputType inputType = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: TextStyle(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.4), fontSize: 12),
          prefixIcon: Icon(icon, color: colors.onSurface.withValues(alpha: 0.5), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
