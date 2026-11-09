import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/station.dart';
import '../providers/transit_provider.dart';
import '../widgets/banner_ad_widget.dart';

class StationFacilitiesScreen extends StatefulWidget {
  const StationFacilitiesScreen({super.key});

  @override
  State<StationFacilitiesScreen> createState() => _StationFacilitiesScreenState();
}

class _StationFacilitiesScreenState extends State<StationFacilitiesScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final transit = Provider.of<TransitProvider>(context);

    final filtered = transit.stations.where((s) {
      if (_filter == 'Parking') return s.facilities.hasParking;
      if (_filter == 'ATM') return s.facilities.hasAtm;
      if (_filter == 'Escalator') return s.facilities.hasEscalator;
      if (_filter == 'Restroom') return s.facilities.hasRestroom;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Station Facilities & Amenities',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['All', 'Parking', 'ATM', 'Escalator', 'Restroom'].map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _filter = f);
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Stations List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final s = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                          Expanded(
                            child: Text(
                              s.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (s.isInterchange)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Interchange',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFacilityBadge(
                            label: 'Parking',
                            icon: Icons.local_parking,
                            available: s.facilities.hasParking,
                          ),
                          _buildFacilityBadge(
                            label: 'Escalators',
                            icon: Icons.escalator,
                            available: s.facilities.hasEscalator,
                          ),
                          _buildFacilityBadge(
                            label: 'Elevator',
                            icon: Icons.elevator,
                            available: s.facilities.hasElevator,
                          ),
                          _buildFacilityBadge(
                            label: 'ATM',
                            icon: Icons.atm,
                            available: s.facilities.hasAtm,
                          ),
                          _buildFacilityBadge(
                            label: 'Restrooms',
                            icon: Icons.wc,
                            available: s.facilities.hasRestroom,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildFacilityBadge({
    required String label,
    required IconData icon,
    required bool available,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: available ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: available ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: available ? Colors.green.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: available ? Colors.green.shade800 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
