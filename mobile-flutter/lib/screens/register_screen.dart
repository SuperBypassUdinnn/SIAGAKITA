import 'package:flutter/material.dart';
import 'biodata_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;

  // Controllers for Step 0 (Form)
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ktpNoController = TextEditingController();
  final _nameKtpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  // Controllers for Step 1 (OTP)
  final _otpController = TextEditingController();

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _register();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _register() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BiodataScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: colors.onBackground,
          onPressed: _prevStep,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isActive = index <= _currentStep;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: isActive ? 24 : 12,
                    decoration: BoxDecoration(
                      color: isActive ? primaryColor : colors.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(colors, primaryColor),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: primaryColor.withValues(alpha: 0.5),
                ),
                child: Text(
                  _currentStep == 3 ? 'Lanjut Isi Biodata' : 'Lanjut',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (_currentStep == 0) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun?', style: TextStyle(color: colors.onBackground.withValues(alpha: 0.6))),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Masuk sekarang', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(ColorScheme colors, Color primaryColor) {
    if (_currentStep == 0) {
      return _buildFormStep(colors);
    } else if (_currentStep == 1) {
      return _buildOTPStep(colors, primaryColor);
    } else if (_currentStep == 2) {
      return _buildKtpPhotoStep(colors, primaryColor);
    } else {
      return _buildFacePhotoStep(colors, primaryColor);
    }
  }

  Widget _buildFormStep(ColorScheme colors) {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Buat Akun Baru', textAlign: TextAlign.center, style: TextStyle(color: colors.onBackground, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('Mari bergabung ke dalam jejaring keselamatan kami.', textAlign: TextAlign.center, style: TextStyle(color: colors.onBackground.withValues(alpha: 0.6), fontSize: 14)),
        const SizedBox(height: 32),
        _buildTextField(_usernameController, 'Username', Icons.alternate_email, colors),
        _buildTextField(_nameKtpController, 'Nama Sesuai KTP', Icons.person_outline, colors),
        _buildTextField(_ktpNoController, 'Nomor KTP', Icons.badge_outlined, colors, inputType: TextInputType.number),
        _buildTextField(_phoneController, 'Nomor Telepon', Icons.phone, colors, inputType: TextInputType.phone),
        _buildTextField(_emailController, 'Email', Icons.email_outlined, colors, inputType: TextInputType.emailAddress),
        _buildTextField(_passwordController, 'Kata Sandi', Icons.lock_outline, colors, obscure: true),
        _buildTextField(_repeatPasswordController, 'Ulangi Kata Sandi', Icons.lock_reset, colors, obscure: true),
      ],
    );
  }

  Widget _buildOTPStep(ColorScheme colors, Color primaryColor) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.message_outlined, size: 64, color: primaryColor),
        const SizedBox(height: 24),
        Text('Verifikasi Nomor', textAlign: TextAlign.center, style: TextStyle(color: colors.onBackground, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('Masukkan kode OTP yang kami kirimkan ke\n${_phoneController.text.isNotEmpty ? _phoneController.text : "nomor telepon Anda"}', textAlign: TextAlign.center, style: TextStyle(color: colors.onBackground.withValues(alpha: 0.6), fontSize: 14)),
        const SizedBox(height: 32),
        _buildTextField(_otpController, 'Kode OTP', Icons.password, colors, inputType: TextInputType.number),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // Logika resend OTP
          },
          child: Text('Kirim ulang kode OTP', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildKtpPhotoStep(ColorScheme colors, Color primaryColor) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.credit_card, size: 64, color: primaryColor),
        const SizedBox(height: 24),
        Text('Foto KTP', textAlign: TextAlign.center, style: TextStyle(color: colors.onBackground, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('Mohon berikan foto KTP asli Anda untuk keperluan verifikasi keamanan.', textAlign: TextAlign.center, style: TextStyle(color: colors.onBackground.withValues(alpha: 0.6), fontSize: 14)),
        const SizedBox(height: 32),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.onSurface.withValues(alpha: 0.2), style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 40, color: colors.onSurface.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text('Ketuk untuk mengambil foto KTP', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFacePhotoStep(ColorScheme colors, Color primaryColor) {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.face, size: 64, color: primaryColor),
        const SizedBox(height: 24),
        Text('Foto Wajah', textAlign: TextAlign.center, style: TextStyle(color: colors.onBackground, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('Ambil foto wajah (selfie) untuk pencocokan biometrik.', textAlign: TextAlign.center, style: TextStyle(color: colors.onBackground.withValues(alpha: 0.6), fontSize: 14)),
        const SizedBox(height: 32),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: colors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: colors.onSurface.withValues(alpha: 0.2), style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_front, size: 40, color: colors.onSurface.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text('Ketuk untuk\nSelfie', textAlign: TextAlign.center, style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, ColorScheme colors, {bool obscure = false, TextInputType inputType = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: inputType,
        style: TextStyle(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.4)),
          prefixIcon: Icon(icon, color: colors.onSurface.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
