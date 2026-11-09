import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/monetization_provider.dart';
import 'login_screen.dart';

class PrimePaywallScreen extends StatefulWidget {
  const PrimePaywallScreen({super.key});

  @override
  State<PrimePaywallScreen> createState() => _PrimePaywallScreenState();
}

class _PrimePaywallScreenState extends State<PrimePaywallScreen> {
  bool _isProcessing = false;

  Future<void> _handlePrimeCheckout() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final monetization = Provider.of<MonetizationProvider>(context, listen: false);

    // 1. Mandatory Login: Prime Commuter Pass cannot be purchased without an account
    if (!auth.isLoggedIn) {
      final signedIn = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(
            messagePrompt: 'Please sign in with Google or Email to unlock and bind your Prime Commuter Pass',
          ),
        ),
      );
      if (signedIn != true && !auth.isLoggedIn) {
        return; // User canceled sign-in
      }
    }

    // 2. Initiate Razorpay Checkout Flow
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2)); // Simulate Razorpay UPI / Card payment

    await monetization.upgradeToPrime(
      paymentId: 'pay_rzp_${DateTime.now().millisecondsSinceEpoch}',
      email: auth.email,
      userId: auth.user?.uid,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.verified, color: Colors.green, size: 28),
              const SizedBox(width: 10),
              Text(
                'Welcome to Prime!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Text(
            'Your Prime Commuter Pass is now active and permanently bound to ${auth.email.isNotEmpty ? auth.email : "your account"}.\n\nAll ads have been removed and premium perks unlocked forever.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // back to home
              },
              child: const Text('Start Exploring'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final monetization = Provider.of<MonetizationProvider>(context);

    final hours = monetization.timeLeft.inHours.toString().padLeft(2, '0');
    final minutes = (monetization.timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (monetization.timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              final restored = await monetization.restorePurchase();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(restored
                        ? 'Prime pass restored successfully!'
                        : 'No existing purchase found to restore.'),
                  ),
                );
              }
            },
            child: Text(
              'Restore',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C20), Color(0xFF1E143E), Color(0xFF11172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 10),
                    // Header Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium, color: Colors.amber, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'LIFETIME PRIME PASS',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.amber,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Supercharge Your Daily Commute',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pay once. Enjoy ultra-smooth, ad-free transit navigation forever.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Countdown Urgency Timer Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.alarm, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Special Discount Ends in: ',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$hours:$minutes:$seconds',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.amberAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Perks List
                    _buildPerkItem(
                      icon: Icons.block,
                      title: '100% Ad-Free Experience',
                      subtitle: 'Zero banner, interstitial, or video interruptions forever.',
                    ),
                    _buildPerkItem(
                      icon: Icons.polyline,
                      title: 'Draw Route Directly on Metro Map',
                      subtitle: 'Live glowing line overlay on the 4K vector transit map.',
                    ),
                    _buildPerkItem(
                      icon: Icons.compare_arrows,
                      title: 'Dual Route Comparison',
                      subtitle: 'Compare Fastest vs Fewest Line changes simultaneously.',
                    ),
                    _buildPerkItem(
                      icon: Icons.dark_mode,
                      title: 'True OLED Dark Mode',
                      subtitle: 'Save battery and eyes during late-night subway rides.',
                    ),
                    _buildPerkItem(
                      icon: Icons.cloud_done,
                      title: 'Google Account Cloud Sync',
                      subtitle: 'Reinstall on any Android or iOS device anytime without repurchasing.',
                    ),
                  ],
                ),
              ),

              // Bottom Paywall Checkout CTA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161226),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIFETIME COMMUTER LICENSE',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '₹${monetization.currentPrice}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${monetization.originalPrice}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white38,
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'SAVE ${monetization.discountPercent}%',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handlePrimeCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isProcessing
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock_open, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Unlock Prime Pass • ₹${monetization.currentPrice}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No recurring subscriptions. One-time payment via Razorpay / UPI.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerkItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.amber, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
