import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/monetization_provider.dart';
import 'providers/transit_provider.dart';
import 'services/admob_service.dart';
import 'services/transit_sync_service.dart';
import 'views/home_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Catch all Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('MetroPulse Framework Error: ${details.exceptionAsString()}');
    };

    // Catch platform and async unhandled errors (prevents cold boot crashes)
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('MetroPulse Platform Error: $error\n$stack');
      return true; // handled, prevent process crash
    };

    // Initialize Firebase safely without throwing if unavailable
    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        await Firebase.initializeApp();
      }
      TransitSyncService.init();
    } catch (e) {
      debugPrint('Firebase startup notice: $e');
    }

    // Custom ErrorWidget builder to prevent red unhandled exception screens
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sync_problem_rounded, color: Colors.amber, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Transit Data Temporarily Refreshing',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please restart the route search.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    };

    // Immediately launch UI so user never experiences launch freeze
    runApp(const MetroPulseApp());

    // Safely initialize AdMob asynchronously without blocking app launch
    try {
      unawaited(AdMobService.initialize());
    } catch (e) {
      debugPrint('AdMob startup notice: $e');
    }
  }, (error, stack) {
    debugPrint('MetroPulse Zone Error: $error\n$stack');
  });
}

class MetroPulseApp extends StatelessWidget {
  const MetroPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0066CC),
        primary: const Color(0xFF0066CC),
        secondary: const Color(0xFF00B4D8),
        surface: const Color(0xFFF9FAFB),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1E293B),
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MonetizationProvider()),
        ChangeNotifierProvider(create: (_) => TransitProvider()),
      ],
      child: MaterialApp(
        title: 'MetroPulse',
        debugShowCheckedModeBanner: false,
        theme: theme,
        // Zero-Friction Launch: Opens directly to Home Dashboard without ANY login screen
        home: const HomeScreen(),
      ),
    );
  }
}
