import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/transit_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/station_picker_sheet.dart';

class FareCalculatorScreen extends StatefulWidget {
  const FareCalculatorScreen({super.key});

  @override
  State<FareCalculatorScreen> createState() => _FareCalculatorScreenState();
}

class _FareCalculatorScreenState extends State<FareCalculatorScreen> {
  void _openStationPicker({required bool isOrigin}) {
    final transit = Provider.of<TransitProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StationPickerSheet(
          isOrigin: isOrigin,
          stations: transit.stations,
          onSelected: (station) {
            if (isOrigin) {
              transit.setOrigin(station);
            } else {
              transit.setDestination(station);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transit = Provider.of<TransitProvider>(context);
    final route = transit.fastestRoute;
    final currency = transit.activeCity.currencySymbol;

    final standardFare = route?.fareAmount ?? 30;
    final smartCardFare = (standardFare * 0.9).round();
    final peakOffPeakDiscount = (standardFare * 0.8).round();

    final totalHops = route != null ? (route.totalStationsCount - 1).clamp(1, 100) : 10;
    final totalTime = route?.travelTimeMinutes ?? 25;
    final totalDistance = route?.estimatedDistanceKm ?? 14.5;
    final totalChanges = route?.numberOfInterchanges ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fare & Ticket Calculator',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert),
            tooltip: 'Swap Origin & Destination',
            onPressed: transit.swapStations,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Interactive Station Pickers Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _openStationPicker(isOrigin: true),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.trip_origin, color: Colors.green, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'FROM (ORIGIN)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey.shade500,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      transit.originStation?.name ?? 'Tap to select origin station',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      InkWell(
                        onTap: () => _openStationPicker(isOrigin: false),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TO (DESTINATION)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey.shade500,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      transit.destinationStation?.name ?? 'Tap to select destination station',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Journey Stats Quick Badge Bar
                if (route != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickStat(Icons.directions_subway, '$totalHops', 'Stations'),
                        Container(width: 1, height: 28, color: Colors.grey.withOpacity(0.3)),
                        _buildQuickStat(Icons.schedule, '$totalTime min', 'Travel Time'),
                        Container(width: 1, height: 28, color: Colors.grey.withOpacity(0.3)),
                        _buildQuickStat(Icons.sync_alt, '$totalChanges', 'Line Switch'),
                        Container(width: 1, height: 28, color: Colors.grey.withOpacity(0.3)),
                        _buildQuickStat(Icons.straighten, '$totalDistance km', 'Distance'),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),

                // Fare Breakdown Cards
                Text(
                  'TICKET & FARE OPTIONS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),

                // Standard Token Fare
                _buildFareCard(
                  title: 'Standard Paper QR / Token',
                  subtitle: 'Single journey standard token rate',
                  price: '$currency$standardFare',
                  icon: Icons.confirmation_number_outlined,
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),

                // Smart Card Discount (10% OFF)
                _buildFareCard(
                  title: 'Smart Card / Metro NCMC (10% OFF)',
                  subtitle: 'Automatic 10% discount on every journey',
                  price: '$currency$smartCardFare',
                  icon: Icons.credit_card,
                  color: Colors.green,
                  tag: 'SAVE 10%',
                ),
                const SizedBox(height: 10),

                // Off-Peak Discount (20% OFF)
                _buildFareCard(
                  title: 'Non-Peak Hours Discount (20% OFF)',
                  subtitle: 'Entry before 08:00 AM, 12:00-05:00 PM, or after 09:00 PM',
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
                    borderRadius: BorderRadius.circular(16),
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
                      const SizedBox(height: 12),
                      _buildSlabRow('0 - 2 km (1-2 stations)', '$currency 10', totalDistance <= 2),
                      _buildSlabRow('2 - 5 km (3-5 stations)', '$currency 20', totalDistance > 2 && totalDistance <= 5),
                      _buildSlabRow('5 - 12 km (6-9 stations)', '$currency 30', totalDistance > 5 && totalDistance <= 12),
                      _buildSlabRow('12 - 21 km (10-15 stations)', '$currency 40', totalDistance > 12 && totalDistance <= 21),
                      _buildSlabRow('21 - 32 km (16-22 stations)', '$currency 50', totalDistance > 21 && totalDistance <= 32),
                      _buildSlabRow('> 32 km (23+ stations)', '$currency 60', totalDistance > 32),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
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

  Widget _buildSlabRow(String slab, String cost, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isCurrent ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isCurrent)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('THIS ROUTE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              Text(
                slab,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                  color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
            ],
          ),
          Text(
            cost,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isCurrent ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
