import 'package:flutter/material.dart';
import '../../core/localization/app_localization.dart';
import '../../core/services/otp_service.dart';
import 'biodata_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 0: Data Akun
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureRepeat = true;

  // Fix #3: password strength
  int _passwordStrength = 0; // 0=empty, 1=weak, 2=medium, 3=strong

  // Step 1: OTP
  final _otpController = TextEditingController();
  bool _isResendCooldown = false;
  int _cooldownSeconds = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ─── Password Strength (Fix #3) ─────────────────────────────────────────

  void _updatePasswordStrength(String value) {
    int strength = 0;
    if (value.isEmpty) {
      setState(() => _passwordStrength = 0);
      return;
    }
    if (value.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(value)) strength++;
    if (RegExp(r'[0-9]').hasMatch(value)) strength++;
    if (RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:"\\|,.<>/?]').hasMatch(value)) {
      strength++;
    }
    // Map 4-point score → 3-level strength
    setState(() {
      if (strength <= 1) {
        _passwordStrength = 1; // weak
      } else if (strength <= 2) {
        _passwordStrength = 2; // medium
      } else {
        _passwordStrength = 3; // strong
      }
    });
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 1:
        return 'Lemah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Kuat ✓';
      default:
        return '';
    }
  }

  // ─── Validators ────────────────────────────────────────────────────────────

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName tidak boleh kosong';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nomor telepon tidak boleh kosong';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Nomor telepon minimal 10 digit';
    if (!RegExp(r'^(\+62|62|0)8').hasMatch(value.trim())) {
      return 'Nomor harus diawali 08, 628, atau +628';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (value.length < 8) return 'Minimal 8 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Harus mengandung huruf besar';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Harus mengandung angka';
    if (!RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:"\\|,.<>/?]').hasMatch(value)) {
      return 'Harus mengandung simbol (!@#\$&*...)';
    }
    return null;
  }

  String? _validateRepeatPassword(String? value) {
    if (value == null || value.isEmpty) return 'Konfirmasi kata sandi tidak boleh kosong';
    if (value != _passwordController.text) return 'Kata sandi tidak cocok';
    return null;
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      _sendOtpAndAdvance();
    } else if (_currentStep == 1) {
      _verifyOtp();
    } else if (_currentStep == 2) {
      setState(() => _currentStep = 3);
    } else {
      _goToBiodata();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Panggil RequestOTP ke backend, lalu pindah ke step OTP.
  Future<void> _sendOtpAndAdvance() async {
    setState(() => _isLoading = true);
    try {
      await OTPService.requestOTP(_phoneController.text.trim());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isResendCooldown = true;
        _cooldownSeconds = 60;
        _currentStep = 1;
      });
      _startCooldown();
    } on OTPException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghubungi server. Periksa koneksi.')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan kode OTP 6 digit'.tr(context))),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await OTPService.verifyOTP(
        _phoneController.text.trim(),
        _otpController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _currentStep = 2;
      });
    } on OTPException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghubungi server. Periksa koneksi.')),
      );
    }
  }

  void _requestOtp() {
    if (_isResendCooldown) return;
    _sendOtpAndAdvance();
  }

  void _startCooldown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _cooldownSeconds--);
      if (_cooldownSeconds <= 0) {
        setState(() => _isResendCooldown = false);
        return false;
      }
      return true;
    });
  }

  void _goToBiodata() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BiodataScreen()),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: colors.onSurface,
          onPressed: _prevStep,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isActive = index <= _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: isActive ? 24 : 12,
                    decoration: BoxDecoration(
                      color: isActive
                          ? primaryColor
                          : colors.onSurface.withValues(alpha: 0.2),
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
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: primaryColor.withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _currentStep == 3
                            ? 'Lanjut Isi Biodata'.tr(context)
                            : 'Lanjut'.tr(context),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              if (_currentStep == 0) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun?'.tr(context),
                      style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.6)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Masuk sekarang'.tr(context),
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold),
                      ),
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
    if (_currentStep == 0) return _buildFormStep(colors, primaryColor);
    if (_currentStep == 1) return _buildOTPStep(colors, primaryColor);
    if (_currentStep == 2) return _buildKtpPhotoStep(colors, primaryColor);
    return _buildFacePhotoStep(colors, primaryColor);
  }

  // ─── Step 0: Form Data Akun ─────────────────────────────────────────────

  Widget _buildFormStep(ColorScheme colors, Color primaryColor) {
    final borderRadius = BorderRadius.circular(16);
    InputDecoration fieldDeco({
      required String hint,
      required IconData icon,
      Widget? suffix,
    }) =>
        InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.4)),
          prefixIcon: Icon(icon, color: colors.onSurface.withValues(alpha: 0.5)),
          suffixIcon: suffix,
          filled: true,
          fillColor: colors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide:
                  BorderSide(color: colors.onSurface.withValues(alpha: 0.15))),
          focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: primaryColor, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide:
                  BorderSide(color: Colors.red.shade400, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: Colors.red.shade400, width: 2)),
          errorStyle: const TextStyle(fontSize: 11, height: 1.3),
        );

    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('step0'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Buat Akun Baru'.tr(context),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: colors.onSurface,
                fontSize: 26,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Mari bergabung ke dalam jejaring keselamatan kami.'.tr(context),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.6), fontSize: 14),
          ),
          const SizedBox(height: 32),

          // Nama Lengkap
          TextFormField(
            controller: _fullNameController,
            style: TextStyle(color: colors.onSurface),
            validator: (v) => _validateRequired(v, 'Nama lengkap'),
            decoration: fieldDeco(hint: 'Nama Lengkap', icon: Icons.person_outline),
          ),
          const SizedBox(height: 16),

          // Nomor Telepon
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: colors.onSurface),
            validator: _validatePhone,
            decoration: fieldDeco(hint: 'Nomor Telepon', icon: Icons.phone),
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: colors.onSurface),
            validator: _validateEmail,
            decoration: fieldDeco(hint: 'Email', icon: Icons.email_outlined),
          ),
          const SizedBox(height: 16),

          // Password + strength bar
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: colors.onSurface),
            validator: _validatePassword,
            onChanged: _updatePasswordStrength,
            decoration: fieldDeco(
              hint: 'Kata Sandi',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colors.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          // ── Fix #3: Password Strength Bar ─────────────────────────────
          if (_passwordStrength > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      color: _passwordStrength >= 1
                          ? _strengthColor
                          : colors.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      color: _passwordStrength >= 2
                          ? _strengthColor
                          : colors.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      color: _passwordStrength >= 3
                          ? _strengthColor
                          : colors.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _strengthLabel,
                    key: ValueKey(_passwordStrength),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _strengthColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // Ulangi Kata Sandi
          TextFormField(
            controller: _repeatPasswordController,
            obscureText: _obscureRepeat,
            style: TextStyle(color: colors.onSurface),
            validator: _validateRepeatPassword,
            decoration: fieldDeco(
              hint: 'Ulangi Kata Sandi',
              icon: Icons.lock_reset,
              suffix: IconButton(
                icon: Icon(
                  _obscureRepeat
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colors.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureRepeat = !_obscureRepeat),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: OTP ────────────────────────────────────────────────────────

  Widget _buildOTPStep(ColorScheme colors, Color primaryColor) {
    final borderRadius = BorderRadius.circular(16);
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.message_outlined, size: 64, color: primaryColor),
        const SizedBox(height: 24),
        Text(
          'Verifikasi Nomor'.tr(context),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colors.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Masukkan kode OTP yang kami kirimkan via WhatsApp ke\n${_phoneController.text.isNotEmpty ? _phoneController.text : "nomor telepon Anda".tr(context)}',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.6), fontSize: 14),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colors.onSurface,
              fontSize: 24,
              letterSpacing: 8,
              fontWeight: FontWeight.bold),
          maxLength: 6,
          decoration: InputDecoration(
            hintText: '------',
            hintStyle: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.3),
                letterSpacing: 8,
                fontSize: 24),
            counterText: '',
            filled: true,
            fillColor: colors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            enabledBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                    color: colors.onSurface.withValues(alpha: 0.15))),
            focusedBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(color: primaryColor, width: 2)),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _isResendCooldown ? null : _requestOtp,
          child: Text(
            _isResendCooldown
                ? '${'Kirim ulang dalam'.tr(context)} ${_cooldownSeconds}s'
                : 'Kirim ulang kode OTP'.tr(context),
            style: TextStyle(
              color: _isResendCooldown
                  ? colors.onSurface.withValues(alpha: 0.4)
                  : primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 2: KTP Photo ─────────────────────────────────────────────────

  Widget _buildKtpPhotoStep(ColorScheme colors, Color primaryColor) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.credit_card, size: 64, color: primaryColor),
        const SizedBox(height: 24),
        Text(
          'Foto KTP'.tr(context),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colors.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Foto KTP bersifat opsional dan hanya digunakan untuk verifikasi akun oleh admin. Kamu bisa lewati langkah ini dan melengkapinya nanti melalui halaman profil.'
              .tr(context),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.6), fontSize: 14),
        ),
        const SizedBox(height: 32),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.2),
                style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt,
                  size: 40, color: colors.onSurface.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(
                'Ketuk untuk mengambil foto KTP'.tr(context),
                style:
                    TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 4),
              Text(
                '(opsional)'.tr(context),
                style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.4),
                    fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Step 3: Selfie ────────────────────────────────────────────────────

  Widget _buildFacePhotoStep(ColorScheme colors, Color primaryColor) {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.face, size: 64, color: primaryColor),
        const SizedBox(height: 24),
        Text(
          'Foto Wajah'.tr(context),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colors.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Ambil foto wajah (selfie) untuk pencocokan biometrik.'.tr(context),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.6), fontSize: 14),
        ),
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                  color: colors.onSurface.withValues(alpha: 0.2),
                  style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_front,
                    size: 40, color: colors.onSurface.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text(
                  'Ketuk untuk\nSelfie'.tr(context),
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
