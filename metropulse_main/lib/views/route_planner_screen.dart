import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/route_result.dart';
import '../models/station.dart';
import '../providers/monetization_provider.dart';
import '../providers/transit_provider.dart';
import '../services/admob_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/station_picker_sheet.dart';
import '../widgets/vertical_route_timeline.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  RouteMode _selectedMode = RouteMode.fastest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final monetization = Provider.of<MonetizationProvider>(context, listen: false);
      AdMobService.onRouteSearched(isProUser: monetization.isPro);
    });
  }

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
            final monetization = Provider.of<MonetizationProvider>(context, listen: false);
            AdMobService.onRouteSearched(isProUser: monetization.isPro);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transit = Provider.of<TransitProvider>(context);
    final route = _selectedMode == RouteMode.fastest
        ? transit.fastestRoute
        : transit.fewestChangesRoute;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Route Planner',
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
          // Station Pickers Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.trip_origin, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _openStationPicker(isOrigin: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            transit.originStation?.name ?? 'Select From Station',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _openStationPicker(isOrigin: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            transit.destinationStation?.name ?? 'Select Destination Station',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dual Route Mode Selector Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedMode = RouteMode.fastest);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedMode == RouteMode.fastest
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bolt,
                                  size: 16,
                                  color: _selectedMode == RouteMode.fastest
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Fastest Route',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedMode == RouteMode.fastest
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedMode = RouteMode.fewestChanges);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedMode == RouteMode.fewestChanges
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.alt_route,
                                  size: 16,
                                  color: _selectedMode == RouteMode.fewestChanges
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Fewest Changes',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedMode == RouteMode.fewestChanges
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Route Results Content
          Expanded(
            child: route == null
                ? Center(
                    child: Text(
                      'Select Origin and Destination to calculate route',
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Journey Summary Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              title: 'TRAVEL TIME',
                              value: '${route.travelTimeMinutes} mins',
                              icon: Icons.timer_outlined,
                            ),
                            _buildDivider(),
                            _buildSummaryItem(
                              title: 'CHANGES',
                              value: '${route.numberOfInterchanges}',
                              icon: Icons.sync_alt,
                            ),
                            _buildDivider(),
                            _buildSummaryItem(
                              title: 'STATIONS',
                              value: '${route.totalStationsCount}',
                              icon: Icons.train_outlined,
                            ),
                            _buildDivider(),
                            _buildSummaryItem(
                              title: 'FARE',
                              value: '${route.currencySymbol}${route.fareAmount}',
                              icon: Icons.confirmation_number_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section Title
                      Text(
                        'JOURNEY TIMELINE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Vertical Route Timeline
                      VerticalRouteTimeline(route: route),
                    ],
                  ),
          ),

          // Bottom Sticky Banner Ad
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.grey.withOpacity(0.25),
    );
  }
}


