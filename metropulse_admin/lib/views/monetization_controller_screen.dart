import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_control_provider.dart';

class MonetizationControllerScreen extends StatefulWidget {
  const MonetizationControllerScreen({super.key});

  @override
  State<MonetizationControllerScreen> createState() => _MonetizationControllerScreenState();
}

class _MonetizationControllerScreenState extends State<MonetizationControllerScreen> {
  late TextEditingController _priceCtrl;
  late TextEditingController _originalPriceCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _hoursCtrl;

  @override
  void initState() {
    super.initState();
    final admin = Provider.of<AdminControlProvider>(context, listen: false);
    _priceCtrl = TextEditingController(text: admin.config.primePrice.toString());
    _originalPriceCtrl = TextEditingController(text: admin.config.primeOriginalPrice.toString());
    _discountCtrl = TextEditingController(text: admin.config.primeDiscountPercent.toString());
    _hoursCtrl = TextEditingController(text: admin.config.countdownHours.toString());
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _discountCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  void _savePricing() {
    final price = int.tryParse(_priceCtrl.text) ?? 49;
    final original = int.tryParse(_originalPriceCtrl.text) ?? 149;
    final discount = int.tryParse(_discountCtrl.text) ?? 67;
    final hours = int.tryParse(_hoursCtrl.text) ?? 6;

    Provider.of<AdminControlProvider>(context, listen: false).updatePrimePricing(
      price: price,
      originalPrice: original,
      discountPercent: discount,
      countdownHours: hours,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prime Pass Pricing & Countdown synced to client paywalls!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminControlProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monetization & AdMob Control',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: AdMob Global Switches
          Text(
            'ADMOB AD ENGINE SWITCHES',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),

          // Master Kill-Switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: admin.config.adsEnabled ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            admin.config.adsEnabled ? Icons.check_circle : Icons.pause_circle,
                            color: admin.config.adsEnabled ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Global AdMob Kill-Switch',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        admin.config.adsEnabled
                            ? 'Banners, Interstitials & Rewarded ads are actively serving'
                            : 'All ad requests immediately suppressed across all devices',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: admin.config.adsEnabled,
                  onChanged: (val) => admin.toggleAds(val),
                  activeTrackColor: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interstitial Frequency Slider
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Interstitial Ad Frequency',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Every ${admin.config.interstitialFrequency} searches',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Controls how many route calculations a free commuter performs before an interstitial ad displays.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                ),
                Slider(
                  value: admin.config.interstitialFrequency.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '${admin.config.interstitialFrequency}',
                  onChanged: (val) => admin.setInterstitialFrequency(val.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Dynamic Prime Pricing
          Text(
            'DYNAMIC PRIME PRICING & PROMOTIONS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prime Discount Price',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _originalPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Original Strikethrough',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _discountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Discount Badge %',
                          suffixText: '%',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _hoursCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Countdown Duration (Hours)',
                          suffixText: 'hrs',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _savePricing,
                    icon: const Icon(Icons.sync),
                    label: Text(
                      'Publish Dynamic Pricing to Apps',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                    ),
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
