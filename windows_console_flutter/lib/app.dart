import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/instansi/presentation/instansi_shell.dart';

class SiagaKitaConsoleApp extends StatelessWidget {
  const SiagaKitaConsoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiagaKita Instansi Console',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const InstansiShell(),
    );
  }
}
