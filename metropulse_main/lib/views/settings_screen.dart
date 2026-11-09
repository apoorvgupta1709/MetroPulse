import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/monetization_provider.dart';
import 'prime_paywall_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final monetization = Provider.of<MonetizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings & About',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Identity Header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: const Icon(Icons.subway_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  'MetroPulse',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Urban Transit & Commuter Engine',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Prime Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: monetization.isPro ? Colors.green.withOpacity(0.12) : Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: monetization.isPro ? Colors.green : Colors.amber,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  monetization.isPro ? Icons.verified : Icons.lock_outline,
                  color: monetization.isPro ? Colors.green : Colors.amber.shade900,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monetization.isPro ? 'Prime Commuter Pass Active' : 'Free Commuter Tier',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        monetization.isPro
                            ? 'All ads removed • 4K Maps • Route Overlays'
                            : 'Upgrade to remove ads and unlock 4K route map overlays',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (!monetization.isPro)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrimePaywallScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    child: Text(
                      'Upgrade',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preferences
          Text(
            'PREFERENCES',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('Transit Network Language', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            subtitle: const Text('English & Regional Scripts (Hindi, etc.)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          ),
          ListTile(
            leading: const Icon(Icons.offline_pin_outlined),
            title: Text('Offline Graph Database', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            subtitle: const Text('Up-to-date (Version 2026.11)'),
            trailing: const Icon(Icons.check, color: Colors.green),
          ),
          const Divider(height: 24),

          // Legal & About
          Text(
            'LEGAL & PRIVACY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy Policy', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            onTap: () => _showPrivacyPolicy(context),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text('Terms of Service', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            onTap: () => _showTerms(context),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          ),
          const SizedBox(height: 40),

          // Mandatory Signature Attribution Placement
          Center(
            child: Column(
              children: [
                Text(
                  'v1.0.0 • Made with ❤️ by Apoorv',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MetroPulse © 2026 All Rights Reserved.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'MetroPulse respects your privacy. We do not sell or track your personal location history. Location coordinates are strictly processed locally on your device to calculate distance to the nearest transit stations.\n\nAll payments are processed securely through Razorpay in compliance with RBI guidelines.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'MetroPulse is an independent transit navigation tool and is not officially affiliated with DMRC, MMRDA, BMRCL, or other metro authorities. Schedules and fares are curated from public domain timetables for commuter convenience.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
