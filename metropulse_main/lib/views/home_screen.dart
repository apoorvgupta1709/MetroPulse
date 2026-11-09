import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/city.dart';
import '../models/service_alert.dart';
import '../providers/auth_provider.dart';
import '../providers/transit_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/prime_highlight_card.dart';
import '../widgets/searchable_city_picker_sheet.dart';
import 'fare_calculator_screen.dart';
import 'interactive_map_screen.dart';
import 'login_screen.dart';
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
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0066CC), Color(0xFF0284C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066CC).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.subway_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'MetroPulse',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          // Elegant City Selector Chip (Opens Searchable Bottom Sheet with 0 Overlap)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              onTap: () => SearchableCityPickerSheet.show(context, transit),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transit.activeCity.isInternational ? '🌍' : '🇮🇳',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 82),
                      child: Text(
                        _getCityDisplayTitle(transit.activeCity),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isLoggedIn) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF1E88E5),
                      backgroundImage: auth.photoUrl != null ? NetworkImage(auth.photoUrl!) : null,
                      child: auth.photoUrl == null
                          ? Text(
                              auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF475569), size: 24),
                tooltip: 'Sign In / Register',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF475569), size: 22),
            tooltip: 'Settings & About',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Active Network Card with 1-Tap Searchable City Switcher
                  _buildActiveNetworkBanner(context, transit),

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

  String _getCityDisplayTitle(City city) {
    return city.name
        .replaceAll(' Metro', '')
        .replaceAll(' Namma', '')
        .replaceAll(' Underground', '');
  }

  Widget _buildActiveNetworkBanner(BuildContext context, TransitProvider transit) {
    final city = transit.activeCity;
    final linesCount = transit.lines.length;
    final stationsCount = transit.stations.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0066CC).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF0066CC), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${city.isInternational ? "🌍 " : "🇮🇳 "}${city.name}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (city.id == 'delhi_ncr')
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Default',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$linesCount Metro Lines • $stationsCount Stations • Offline Ready',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => SearchableCityPickerSheet.show(context, transit),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Switch',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.unfold_more, size: 14, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.trip_origin, color: Color(0xFF16A34A), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                transit.originStation?.name ?? 'Select Departure Station',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: const Color(0xFF1E293B),
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFFDC2626), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                transit.destinationStation?.name ?? 'Select Destination Station',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: const Color(0xFF1E293B),
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
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.swap_vert, size: 24, color: Color(0xFF334155)),
                  tooltip: 'Swap Stations',
                  onPressed: transit.swapStations,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RoutePlannerScreen()),
              ),
              icon: const Icon(Icons.alt_route_rounded, size: 18),
              label: Text(
                'Show Route & Timings',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
            border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
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
