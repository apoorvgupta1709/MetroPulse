import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/city.dart';
import '../models/service_alert.dart';
import '../providers/transit_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/prime_highlight_card.dart';
import 'fare_calculator_screen.dart';
import 'interactive_map_screen.dart';
import 'metro_near_me_screen.dart';
import 'recharge_screen.dart';
import 'route_planner_screen.dart';
import 'settings_screen.dart';
import 'station_facilities_screen.dart';
import 'station_gates_screen.dart';
import 'timings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transit = Provider.of<TransitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.subway_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MetroPulse',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Instant Transit Guide',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Dynamic City Switcher Dropdown
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<City>(
                value: transit.activeCity,
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                borderRadius: BorderRadius.circular(16),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                items: transit.cities.map((City city) {
                  return DropdownMenuItem<City>(
                    value: city,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          city.isInternational ? '🌍 ' : '🇮🇳 ',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(city.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (City? newCity) {
                  if (newCity != null) {
                    transit.switchCity(newCity);
                  }
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings & About',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Service Disruption Marquee (if active alerts exist)
                  if (transit.alerts.isNotEmpty) _buildAlertMarquee(context, transit),

                  // Prime Highlight Card
                  const PrimeHighlightCard(),

                  // Quick Route Search Shortcut Card
                  _buildQuickSearchCard(context, transit),

                  const SizedBox(height: 12),

                  // Feature Grid Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: Text(
                      'TRANSIT TOOLS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  // 8-Card Transit Feature Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.35,
                      children: [
                        _buildFeatureCard(
                          context: context,
                          title: 'Find Metro Route',
                          subtitle: 'Fastest & Fewest Changes',
                          icon: Icons.alt_route_rounded,
                          color: const Color(0xFF1E88E5),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RoutePlannerScreen()),
                          ),
                        ),
                        _buildFeatureCard(
                          context: context,
                          title: 'Interactive Map',
                          subtitle: '4K Crisp Vector Viewer',
                          icon: Icons.map_rounded,
                          color: const Color(0xFF00897B),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const InteractiveMapScreen()),
                          ),
                        ),
                        _buildFeatureCard(
                          context: context,
                          title: 'Fare Calculator',
                          subtitle: 'Slabs & Smart Card Discs',
                          icon: Icons.calculate_rounded,
                          color: const Color(0xFFFB8C00),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FareCalculatorScreen()),
                          ),
                        ),
                        _buildFeatureCard(
                          context: context,
                          title: 'First & Last Timings',
                          subtitle: 'Per Line Schedules',
                          icon: Icons.schedule_rounded,
                          color: const Color(0xFF5E35B1),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TimingsScreen()),
                          ),
                        ),
                        _buildFeatureCard(
                          context: context,
                          title: 'Gates & Exits',
                          subtitle: 'Numbered Gates & Landmarks',
                          icon: Icons.door_front_door_rounded,
                          color: const Color(0xFF43A047),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StationGatesScreen()),
                          ),
                        ),
                        _buildFeatureCard(
                          context: context,
                          title: 'Station Info & Amenities',
                          subtitle: 'Parking, ATM, Escalators',
                          icon: Icons.local_convenience_store_rounded,
                          color: const Color(0xFF039BE5),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StationFacilitiesScreen()),
                          ),
                        ),
                        _buildFeatureCard(
                          context: context,
                          title: 'Recharge Metro Card',
                          subtitle: 'Instant Official Web Portal',
                          icon: Icons.credit_card_rounded,
                          color: const Color(0xFFE53935),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RechargeScreen()),
                          ),
                        ),
                        _buildFeatureCard(
                          context: context,
                          title: 'Metro Near Me',
                          subtitle: 'GPS Nearest Station Finder',
                          icon: Icons.near_me_rounded,
                          color: const Color(0xFF8E24AA),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MetroNearMeScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Signature Attribution Footer
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Made with ❤️ by Apoorv',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // AdMob Sticky Bottom Banner (Auto-hidden for Pro)
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertMarquee(BuildContext context, TransitProvider transit) {
    final alert = transit.alerts.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: alert.severity == AlertSeverity.normal
            ? Colors.green.shade50
            : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: alert.severity == AlertSeverity.normal
              ? Colors.green.shade300
              : Colors.amber.shade400,
        ),
      ),
      child: Row(
        children: [
          Icon(
            alert.severity == AlertSeverity.normal
                ? Icons.check_circle_outline
                : Icons.warning_amber_rounded,
            size: 18,
            color: alert.severity == AlertSeverity.normal
                ? Colors.green.shade800
                : Colors.amber.shade900,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${alert.lineName}: ${alert.headline}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: alert.severity == AlertSeverity.normal
                    ? Colors.green.shade900
                    : Colors.brown.shade900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchCard(BuildContext context, TransitProvider transit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoutePlannerScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.trip_origin, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                transit.originStation?.name ?? 'Select From Station',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoutePlannerScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                transit.destinationStation?.name ?? 'Select To Station',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.swap_vert, size: 28),
                tooltip: 'Swap Stations',
                onPressed: transit.swapStations,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RoutePlannerScreen()),
              ),
              icon: const Icon(Icons.directions, size: 18),
              label: Text(
                'Show Route & Timings',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
