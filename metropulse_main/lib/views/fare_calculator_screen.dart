import 'dart:math' as math;
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

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  int _calculateDynamicFareFromDistance(double distanceKm, int hops, String currency) {
    if (currency == '₹') {
      if (distanceKm <= 2.0 || hops <= 2) return 10;
      if (distanceKm <= 5.0 || hops <= 5) return 20;
      if (distanceKm <= 12.0 || hops <= 9) return 30;
      if (distanceKm <= 21.0 || hops <= 15) return 40;
      if (distanceKm <= 32.0 || hops <= 22) return 50;
      return 60;
    } else if (currency == 'AED') {
      if (distanceKm <= 5.0) return 3;
      if (distanceKm <= 15.0) return 5;
      return 8;
    } else if (currency == '£') {
      if (distanceKm <= 5.0) return 3;
      if (distanceKm <= 12.0) return 4;
      return 6;
    } else {
      if (distanceKm <= 5.0) return 2;
      if (distanceKm <= 12.0) return 3;
      return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transit = Provider.of<TransitProvider>(context);
    final origin = transit.originStation;
    final dest = transit.destinationStation;
    final currency = transit.activeCity.currencySymbol;
    final route = transit.fastestRoute ?? transit.fewestChangesRoute;

    final isSameStation = origin != null && dest != null && origin.id == dest.id;
    final hasBothStations = origin != null && dest != null && !isSameStation;

    int standardFare = 0;
    int smartCardFare = 0;
    int peakOffPeakDiscount = 0;
    int totalHops = 0;
    int totalTime = 0;
    double totalDistance = 0.0;
    int totalChanges = 0;
    bool isMultiNetwork = false;

    if (hasBothStations) {
      if (route != null) {
        standardFare = route.fareAmount;
        totalDistance = route.estimatedDistanceKm;
        totalHops = math.max(1, route.totalStationsCount - 1);
        totalTime = route.travelTimeMinutes;
        totalChanges = route.numberOfInterchanges;

        final lines = route.steps.map((s) => s.line.id.toLowerCase()).toSet();
        isMultiNetwork = lines.any((l) => l.contains('aqua')) && lines.any((l) => !l.contains('aqua'));
      } else {
        final straight = _haversineDistance(origin.latitude, origin.longitude, dest.latitude, dest.longitude);
        totalDistance = double.parse((straight * 1.35).clamp(1.0, 95.0).toStringAsFixed(1));
        totalHops = (totalDistance / 1.6).round().clamp(1, 60);
        totalTime = (totalHops * 2.2).round() + 4;
        totalChanges = (totalHops / 10).floor().clamp(0, 3);
        standardFare = _calculateDynamicFareFromDistance(totalDistance, totalHops, currency);
      }

      smartCardFare = (standardFare * 0.9).round();
      peakOffPeakDiscount = (standardFare * 0.8).round();
    }

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
                        color: Colors.black.withValues(alpha: 0.05),
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
                                  color: Colors.green.withValues(alpha: 0.12),
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
                                      origin?.name ?? 'Tap to select origin station',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: origin == null ? Colors.grey.shade400 : null,
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
                                  color: Colors.redAccent.withValues(alpha: 0.12),
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
                                      dest?.name ?? 'Tap to select destination station',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: dest == null ? Colors.grey.shade400 : null,
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

                // Multi-network banner if applicable
                if (isMultiNetwork)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.alt_route, color: Colors.amber.shade800, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cross-network journey: Integrated fare covers DMRC and NMRC (Aqua Line).',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Prompt when stations are not selected
                if (!hasBothStations && !isSameStation)
                  Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.touch_app_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 12),
                        Text(
                          'Select Origin & Destination',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Choose your boarding and deboarding stations above to see live dynamic token rates, Smart Card discounts, and travel duration.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Notice when origin and destination are identical
                if (isSameStation)
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade800),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Origin and Destination are the same station. Fare: ${currency}0.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Journey Stats Quick Badge Bar
                if (hasBothStations) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickStat(Icons.directions_subway, '$totalHops', 'Stations'),
                        Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
                        _buildQuickStat(Icons.schedule, '$totalTime min', 'Travel Time'),
                        Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
                        _buildQuickStat(Icons.sync_alt, '$totalChanges', 'Line Switch'),
                        Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
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
                ],

                // Fare Matrix Slabs Explainer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
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
                      _buildSlabRow('0 - 2 km (1-2 stations)', '$currency 10', hasBothStations && totalDistance <= 2),
                      _buildSlabRow('2 - 5 km (3-5 stations)', '$currency 20', hasBothStations && totalDistance > 2 && totalDistance <= 5),
                      _buildSlabRow('5 - 12 km (6-9 stations)', '$currency 30', hasBothStations && totalDistance > 5 && totalDistance <= 12),
                      _buildSlabRow('12 - 21 km (10-15 stations)', '$currency 40', hasBothStations && totalDistance > 12 && totalDistance <= 21),
                      _buildSlabRow('21 - 32 km (16-22 stations)', '$currency 50', hasBothStations && totalDistance > 21 && totalDistance <= 32),
                      _buildSlabRow('> 32 km (23+ stations)', '$currency 60', hasBothStations && totalDistance > 32),
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
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
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
        color: isCurrent ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
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
