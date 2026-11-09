import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/transit_provider.dart';
import '../widgets/banner_ad_widget.dart';

class FareCalculatorScreen extends StatefulWidget {
  const FareCalculatorScreen({super.key});

  @override
  State<FareCalculatorScreen> createState() => _FareCalculatorScreenState();
}

class _FareCalculatorScreenState extends State<FareCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    final transit = Provider.of<TransitProvider>(context);
    final route = transit.fastestRoute;
    final currency = transit.activeCity.currencySymbol;

    final standardFare = route?.fareAmount ?? 30;
    final smartCardFare = (standardFare * 0.9).round();
    final peakOffPeakDiscount = (standardFare * 0.8).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fare & Ticket Calculator',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Selection Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trip_origin, color: Colors.green, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              transit.originStation?.name ?? 'Select Origin',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              transit.destinationStation?.name ?? 'Select Destination',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Fare Breakdown Cards
                Text(
                  'TICKET & FARE SLABS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),

                // Standard Token Fare
                _buildFareCard(
                  title: 'Standard Paper Token / QR Code',
                  subtitle: 'Single journey standard token rate',
                  price: '$currency$standardFare',
                  icon: Icons.confirmation_number_outlined,
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),

                // Smart Card Discount (10% OFF)
                _buildFareCard(
                  title: 'Smart Card Fare (10% OFF)',
                  subtitle: 'Automatic 10% discount on every journey',
                  price: '$currency$smartCardFare',
                  icon: Icons.credit_card,
                  color: Colors.green,
                  tag: 'POPULAR',
                ),
                const SizedBox(height: 10),

                // Off-Peak Discount (20% OFF)
                _buildFareCard(
                  title: 'Non-Peak Hours (20% OFF)',
                  subtitle: 'Before 08:00 AM, 12:00-05:00 PM, after 09:00 PM',
                  price: '$currency$peakOffPeakDiscount',
                  icon: Icons.alarm_on,
                  color: Colors.deepPurple,
                  tag: 'SAVE 20%',
                ),
                const SizedBox(height: 20),

                // Fare Matrix Slabs Explainer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Official Fare Structure (${transit.activeCity.name})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildSlabRow('0 - 2 km (1-2 stations)', '$currency 10'),
                      _buildSlabRow('2 - 5 km (3-5 stations)', '$currency 20'),
                      _buildSlabRow('5 - 12 km (6-9 stations)', '$currency 30'),
                      _buildSlabRow('12 - 21 km (10-15 stations)', '$currency 40'),
                      _buildSlabRow('21 - 32 km (16-22 stations)', '$currency 50'),
                      _buildSlabRow('> 32 km (23+ stations)', '$currency 60'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildFareCard({
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
    required Color color,
    String? tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (tag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlabRow(String slab, String cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(slab, style: GoogleFonts.plusJakartaSans(fontSize: 12)),
          Text(cost, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
