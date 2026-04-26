import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../core/localization/app_localization.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ─── SOS Tap State ──────────────────────────────────────────────────────────
  static const int _requiredTaps = 5;
  static const Duration _tapResetDuration = Duration(milliseconds: 1500);
  static const Duration _confirmDuration = Duration(seconds: 5);

  int _tapCount = 0;
  Timer? _tapResetTimer;

  // ─── Confirm Dialog State ───────────────────────────────────────────────────
  bool _showConfirmDialog = false;
  int _confirmCountdown = 5;
  Timer? _confirmTimer;

  // ─── SOS Sent State ─────────────────────────────────────────────────────────
  bool _showSOSSentBanner = false;
  String? _lastTriggerMethod; // 'user' | 'timeout'

  // ─── Tap Logic ──────────────────────────────────────────────────────────────

  void _onSOSTap() {
    if (_showConfirmDialog) return; // ignore taps while dialog is showing

    HapticFeedback.lightImpact();

    _tapResetTimer?.cancel();

    setState(() {
      _tapCount++;
    });

    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      HapticFeedback.heavyImpact();
      _showConfirmationDialog();
      return;
    }

    // Reset tap count if no new tap arrives within 1.5 seconds
    _tapResetTimer = Timer(_tapResetDuration, () {
      if (mounted) setState(() => _tapCount = 0);
    });
  }

  // ─── Confirm Dialog ─────────────────────────────────────────────────────────

  void _showConfirmationDialog() {
    setState(() {
      _showConfirmDialog = true;
      _confirmCountdown = _confirmDuration.inSeconds;
    });

    _confirmTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _confirmCountdown--);
      HapticFeedback.selectionClick();

      if (_confirmCountdown <= 0) {
        timer.cancel();
        _triggerSOS(triggeredBy: 'timeout');
      }
    });
  }

  void _cancelSOS() {
    _confirmTimer?.cancel();
    setState(() {
      _showConfirmDialog = false;
      _confirmCountdown = 5;
      _tapCount = 0;
    });
  }

  void _triggerSOS({required String triggeredBy}) {
    _confirmTimer?.cancel();
    HapticFeedback.vibrate();

    setState(() {
      _showConfirmDialog = false;
      _confirmCountdown = 5;
      _tapCount = 0;
      _showSOSSentBanner = true;
      _lastTriggerMethod = triggeredBy;
    });

    // TODO: Kirim TRIGGER_SOS event ke WebSocket dengan triggered_by (Task 6)
    // wsService.send(SOSTriggerEvent(triggeredBy: triggeredBy, lat: ..., lng: ...));

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showSOSSentBanner = false);
    });
  }

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    _confirmTimer?.cancel();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          Text(
                            'SiagaKita',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ketuk 5× untuk mengirim SOS'.tr(context),
                            style: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          SiagaKitaApp.themeNotifier.value = isDarkMode
                              ? ThemeMode.light
                              : ThemeMode.dark;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isDarkMode
                                ? []
                                : [
                                    BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10)
                                  ],
                          ),
                          child: Icon(
                            isDarkMode
                                ? Icons.wb_sunny
                                : Icons.nightlight_round,
                            color: isDarkMode
                                ? Colors.amber
                                : Colors.blue[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── SOS Button + Tap Counter ─────────────────────────────
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _onSOSTap,
                        child: SizedBox(
                          width: 250,
                          height: 250,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer progress ring (tap count)
                              if (_tapCount > 0)
                                SizedBox(
                                  width: 240,
                                  height: 240,
                                  child: CircularProgressIndicator(
                                    value: _tapCount / _requiredTaps,
                                    strokeWidth: 8,
                                    backgroundColor: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : primaryColor.withValues(alpha: 0.15),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.orangeAccent,
                                    ),
                                  ),
                                ),
                              // Main SOS Button
                              AnimatedScale(
                                scale: _tapCount > 0 ? 0.96 : 1.0,
                                duration: const Duration(milliseconds: 80),
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        primaryColor,
                                        const Color(0xFFCB5100)
                                      ],
                                    ),
                                    border: Border.all(
                                      color: _tapCount > 0
                                          ? const Color(0xFFFFA265)
                                          : (isDarkMode
                                              ? Colors.white
                                                  .withValues(alpha: 0.2)
                                              : primaryColor
                                                  .withValues(alpha: 0.3)),
                                      width: 8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withValues(
                                            alpha: _tapCount > 0
                                                ? 0.8
                                                : (isDarkMode ? 0.3 : 0.6)),
                                        blurRadius:
                                            _tapCount > 0 ? 50 : 30,
                                        spreadRadius:
                                            _tapCount > 0 ? 10 : (isDarkMode ? 5 : 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Colors.white, size: 60),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'SOS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        'KETUK 5×'.tr(context),
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tap count indicator dots
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_requiredTaps, (i) {
                          final filled = i < _tapCount;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: filled ? 14 : 10,
                            height: filled ? 14 : 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filled
                                  ? primaryColor
                                  : colors.onSurface.withValues(alpha: 0.2),
                              boxShadow: filled
                                  ? [
                                      BoxShadow(
                                          color: primaryColor
                                              .withValues(alpha: 0.5),
                                          blurRadius: 6)
                                    ]
                                  : [],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      AnimatedOpacity(
                        opacity: _tapCount > 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          '$_tapCount/$_requiredTaps',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Bottom Action Cards ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReportScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: isDarkMode
                                  ? []
                                  : [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 10)
                                    ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.secondary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.description_outlined,
                                      color: colors.secondary, size: 28),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Laporkan'.tr(context),
                                  style: TextStyle(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kirim bukti & titik\nlokasi'.tr(context),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: colors.onSurface
                                          .withValues(alpha: 0.5),
                                      fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isDarkMode
                                ? []
                                : [
                                    BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10)
                                  ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(Icons.menu_book_outlined,
                                    color: primaryColor, size: 28),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Edukasi'.tr(context),
                                style: TextStyle(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Panduan\npenyelamatan'.tr(context),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: colors.onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Confirmation Dialog Overlay ────────────────────────────────
            if (_showConfirmDialog)
              _buildConfirmDialog(context, primaryColor, colors),

            // ── SOS Sent Banner ────────────────────────────────────────────
            if (_showSOSSentBanner)
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: -60, end: 0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: child!,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7418),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF7418).withValues(alpha: 0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SINYAL SOS TERKIRIM!'.tr(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bantuan sedang diarahkan ke lokasi Anda.'.tr(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_lastTriggerMethod == 'timeout') ...[
                          const SizedBox(height: 4),
                          Text(
                            '(Terkirim otomatis — konfirmasi habis)'.tr(context),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Confirmation Dialog ─────────────────────────────────────────────────

  Widget _buildConfirmDialog(
      BuildContext context, Color primaryColor, ColorScheme colors) {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon with pulsing glow
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: 0.15),
                  ),
                  child: Icon(Icons.warning_amber_rounded,
                      color: primaryColor, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  'KONFIRMASI SOS'.tr(context),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sinyal darurat akan dikirim otomatis dalam:'.tr(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // Countdown circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                    boxShadow: [
                      BoxShadow(
                          color: primaryColor.withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$_confirmCountdown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                // Countdown progress bar
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _confirmCountdown / _confirmDuration.inSeconds,
                    minHeight: 8,
                    backgroundColor: colors.onSurface.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),

                const SizedBox(height: 28),
                Row(
                  children: [
                    // BATALKAN
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelSOS,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          side: BorderSide(
                              color: colors.onSurface.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'BATALKAN'.tr(context),
                          style: TextStyle(
                            color: colors.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // KIRIM SEKARANG
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _triggerSOS(triggeredBy: 'user'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                          shadowColor: primaryColor.withValues(alpha: 0.5),
                        ),
                        child: Text(
                          'KIRIM!'.tr(context),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
