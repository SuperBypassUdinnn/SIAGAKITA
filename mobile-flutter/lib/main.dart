import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SiagaKitaApp());
}

class SiagaKitaApp extends StatefulWidget {
  const SiagaKitaApp({super.key});

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  @override
  State<SiagaKitaApp> createState() => _SiagaKitaAppState();
}

class _SiagaKitaAppState extends State<SiagaKitaApp> {
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7418); // Oranye Utama

    // Dark Theme Colors
    const Color darkBgColor = Color(0xFF0D1B3E); // Deep Royal Navy
    const Color darkCardColor = Color(0xFF162A5A); // Cobalt Blue
    
    // Light Theme Colors
    const Color lightBgColor = Color(0xFFF1F5F9); // Slate 100
    const Color lightCardColor = Color(0xFFFFFFFF); // White

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SiagaKitaApp.themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'SiagaKita',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: lightBgColor,
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              secondary: Color(0xFF18A3FF),
              surface: lightCardColor,
              background: lightBgColor,
              onSurface: Color(0xFF1E293B),
              onBackground: Color(0xFF1E293B),
            ),
            fontFamily: 'Inter',
            appBarTheme: const AppBarTheme(
              backgroundColor: lightBgColor,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF1E293B)),
              titleTextStyle: TextStyle(color: Color(0xFF1E293B), fontFamily: 'Inter', fontWeight: FontWeight.bold),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: lightCardColor,
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.black54,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: darkBgColor,
            colorScheme: const ColorScheme.dark(
              primary: primaryColor,
              secondary: Color(0xFF18A3FF),
              surface: darkCardColor,
              background: darkBgColor,
              onSurface: Colors.white,
              onBackground: Colors.white,
            ),
            fontFamily: 'Inter',
            appBarTheme: const AppBarTheme(
              backgroundColor: darkBgColor,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF162A5A),
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.white54,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}
