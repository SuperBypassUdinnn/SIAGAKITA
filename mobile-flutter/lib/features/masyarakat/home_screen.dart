import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart'; // To access SiagaKitaApp.themeNotifier
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isHolding = false;
  double _progress = 0.0;
  Timer? _timer;
  bool _showSOSAlert = false;

  void _startHolding() {
    HapticFeedback.heavyImpact(); // Haptic when starting to hold
    setState(() {
      _isHolding = true;
      _progress = 0.0;
      _showSOSAlert = false;
    });

    const updateInterval = Duration(milliseconds: 50);
    const totalDuration = Duration(seconds: 10);
    final totalSteps = totalDuration.inMilliseconds / updateInterval.inMilliseconds;

    _timer = Timer.periodic(updateInterval, (timer) {
      setState(() {
        _progress += 1 / totalSteps;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _timer?.cancel();
          _triggerSOS();
        }
      });
      if ((_progress * 10).toInt() != ((_progress - 1 / totalSteps) * 10).toInt()) {
        HapticFeedback.selectionClick();
      }
    });
  }

  void _stopHolding() {
    if (_progress < 1.0) {
      _timer?.cancel();
      setState(() {
        _isHolding = false;
        _progress = 0.0;
      });
    }
  }

  void _triggerSOS() {
    HapticFeedback.vibrate(); 
    setState(() {
      _isHolding = false;
      _progress = 0.0;
      _showSOSAlert = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSOSAlert = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  // Header
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
                            'Tekan dan tahan untuk bantuan',
                            style: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          SiagaKitaApp.themeNotifier.value = 
                              isDarkMode ? ThemeMode.light : ThemeMode.dark;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                          ),
                          child: Icon(
                            isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                            color: isDarkMode ? Colors.amber : Colors.blue[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // SOS Button with Progress
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isHolding)
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: CircularProgressIndicator(
                              value: _progress,
                              strokeWidth: 8,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        GestureDetector(
                          onTapDown: (_) => _startHolding(),
                          onTapUp: (_) => _stopHolding(),
                          onTapCancel: () => _stopHolding(),
                          child: AnimatedScale(
                            scale: _isHolding ? 0.95 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [primaryColor, const Color(0xFFCB5100)],
                                ),
                                border: Border.all(
                                  color: _isHolding
                                      ? const Color(0xFFFFA265)
                                      : (isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1)),
                                  width: 8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: _isHolding ? 0.6 : 0.3),
                                    blurRadius: _isHolding ? 50 : 30,
                                    spreadRadius: _isHolding ? 10 : 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.white, size: 60),
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
                                    'TAHAN 10 DETIK',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom Action Cards
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReportScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.secondary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.description_outlined,
                                      color: colors.secondary, size: 28),
                                ),
                                const SizedBox(height: 12),
                                Text('Laporkan',
                                    style: TextStyle(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('Kirim bukti & titik\nlokasi',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: colors.onSurface.withValues(alpha: 0.5), fontSize: 10)),
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
                            boxShadow: isDarkMode ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child:
                                    Icon(Icons.menu_book_outlined, color: primaryColor, size: 28),
                              ),
                              const SizedBox(height: 12),
                              Text('Edukasi',
                                  style: TextStyle(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('Panduan\npenyelamatan',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: colors.onSurface.withValues(alpha: 0.5), fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_showSOSAlert)
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: -50, end: 0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: Opacity(
                        opacity: 1.0 - (value / -50).clamp(0.0, 1.0),
                        child: child!,
                      ),
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
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SINYAL SOS TERKIRIM!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bantuan sedang diarahkan ke lokasi Anda.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
}
