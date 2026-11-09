import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/station.dart';
import '../providers/monetization_provider.dart';
import '../providers/transit_provider.dart';
import '../widgets/crisp_vector_map.dart';
import 'home_screen.dart';
import 'prime_paywall_screen.dart';
import 'route_planner_screen.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final GlobalKey<CrispVectorMapState> _mapKey = GlobalKey<CrispVectorMapState>();

  Station? _highlightedStation;
  final bool _overlayActiveRoute = true;
  bool _isFullscreen = false;
  bool _is4KActive = true;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onStationSelected(Station station) {
    setState(() {
      _highlightedStation = station;
      _searchController.text = station.name;
    });
    _searchFocus.unfocus();
    _mapKey.currentState?.panToStation(station);
    _showStationModalSheet(station);
  }

  void _showStationModalSheet(Station station) {
    final transit = Provider.of<TransitProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final lines = transit.lines.where((l) => station.lineIds.contains(l.id)).toList();

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, -4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Station Title & Hindi Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (station.hindiName.isNotEmpty)
                          Text(
                            station.hindiName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (station.isInterchange)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.alt_route, size: 14, color: Colors.amber.shade900),
                          const SizedBox(width: 4),
                          Text(
                            'Interchange',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Connecting Lines Badges
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: lines.map((line) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: line.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: line.color, width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: line.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          line.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: line.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Quick Facilities Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFacilityIcon(Icons.local_parking, 'Parking', station.facilities.hasParking),
                  _buildFacilityIcon(Icons.escalator, 'Escalator', station.facilities.hasEscalator),
                  _buildFacilityIcon(Icons.elevator, 'Elevator', station.facilities.hasElevator),
                  _buildFacilityIcon(Icons.atm, 'ATM', station.facilities.hasAtm),
                  _buildFacilityIcon(Icons.wc, 'Restroom', station.facilities.hasRestroom),
                ],
              ),
              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.trip_origin, size: 16),
                      label: const Text('Depart Here'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        transit.setOrigin(station);
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RoutePlannerScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.location_on, size: 16),
                      label: const Text('Arrive Here'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        transit.setDestination(station);
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RoutePlannerScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFacilityIcon(IconData icon, String label, bool available) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: available ? const Color(0xFF0F172A) : Colors.grey.shade300,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: available ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final transit = Provider.of<TransitProvider>(context);
    final monetization = Provider.of<MonetizationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Back Button & "Search a station to locate" (Matching Reference UI)
            if (!_isFullscreen)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
                ),
                child: Row(
                  children: [
                    // Back Arrow Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 4),

                    // Rounded Station Search Input
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Autocomplete<Station>(
                          displayStringForOption: (s) => s.name,
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Station>.empty();
                            }
                            return transit.searchStations(textEditingValue.text);
                          },
                          onSelected: _onStationSelected,
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search a station to locate',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 22),
                                suffixIcon: controller.text.isNotEmpty || _highlightedStation != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                        onPressed: () {
                                          controller.clear();
                                          setState(() {
                                            _highlightedStation = null;
                                          });
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 32,
                                  constraints: const BoxConstraints(maxHeight: 280),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: options.length,
                                    separatorBuilder: (_, _) => const Divider(height: 1),
                                    itemBuilder: (ctx, i) {
                                      final s = options.elementAt(i);
                                      return ListTile(
                                        dense: true,
                                        leading: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: s.isInterchange ? Colors.amber.shade100 : Colors.blue.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            s.isInterchange ? Icons.alt_route : Icons.subway_rounded,
                                            size: 16,
                                            color: s.isInterchange ? Colors.amber.shade900 : const Color(0xFF0066CC),
                                          ),
                                        ),
                                        title: Text(
                                          s.name,
                                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                                        ),
                                        subtitle: Text(
                                          s.hindiName.isNotEmpty ? s.hindiName : '${s.lineIds.length} Metro Lines',
                                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                        trailing: const Icon(Icons.north_west, size: 14, color: Colors.grey),
                                        onTap: () => onSelected(s),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Map Area with Crisp Vector Canvas
            Expanded(
              child: CrispVectorMap(
                key: _mapKey,
                stations: transit.stations,
                lines: transit.lines,
                activeRoute: _overlayActiveRoute ? transit.fastestRoute : null,
                isPrimeUser: monetization.isPro,
                highlightedStation: _highlightedStation,
                is4KActive: _is4KActive,
                isFullscreen: _isFullscreen,
                onToggle4K: () {
                  setState(() {
                    _is4KActive = !_is4KActive;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_is4KActive
                          ? '4K Ultra-Crisp Vector Engine Active • 0% Blur'
                          : 'Standard Vector Mode'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onToggleFullscreen: () {
                  setState(() {
                    _isFullscreen = !_isFullscreen;
                  });
                },
                onStationTapped: _onStationSelected,
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar (Matching Reference UI: Home, Route, Map (active), Prime)
      bottomNavigationBar: _isFullscreen
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  )
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Home Tab
                      _buildBottomNavItem(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        isSelected: false,
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                      ),

                      // Route Tab
                      _buildBottomNavItem(
                        icon: Icons.alt_route,
                        label: 'Route',
                        isSelected: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RoutePlannerScreen()),
                          );
                        },
                      ),

                      // Map Tab (Active Highlighted Pill)
                      _buildBottomNavItem(
                        icon: Icons.map,
                        label: 'Map',
                        isSelected: true,
                        onTap: () {},
                      ),

                      // Prime Tab
                      _buildBottomNavItem(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Prime',
                        isSelected: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PrimePaywallScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFEDD5) : Colors.transparent, // Peach highlight pill
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? const Color(0xFF9A3412) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? const Color(0xFF9A3412) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
