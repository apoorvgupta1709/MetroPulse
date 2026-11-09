import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/admin_control_provider.dart';
import 'views/admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MetroPulseAdminApp());
}

class MetroPulseAdminApp extends StatelessWidget {
  const MetroPulseAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0F172A),
        primary: const Color(0xFF0284C7),
        surface: const Color(0xFFF8FAFC),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminControlProvider()),
      ],
      child: MaterialApp(
        title: 'MetroPulse Admin',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const AdminDashboardScreen(),
      ),
    );
  }
}
