import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_control_provider.dart';
import 'city_network_cms_screen.dart';
import 'fare_schedule_editor_screen.dart';
import 'live_delay_broadcaster_screen.dart';
import 'map_uploader_screen.dart';
import 'monetization_controller_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminControlProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'MetroPulse Command Center',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_rounded),
            tooltip: 'Sync with Cloud Firestore',
            onPressed: admin.isSyncing
                ? null
                : () async {
                    await admin.seedInitialDataToCloud();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(admin.syncStatusMessage.isNotEmpty
                              ? admin.syncStatusMessage
                              : 'Synced with Cloud Firestore!'),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mandatory Signature Branding Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'MetroPulse Master Admin',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'FIREBASE CONNECTED',
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
                        'Made with ❤️ by Apoorv • Operator Console',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Firebase Live Cloud Sync Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Real-Time Firestore Sync',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        'Changes push live over-the-air to commuter apps & work offline.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: admin.isSyncing
                      ? null
                      : () async {
                          await admin.seedInitialDataToCloud();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(admin.syncStatusMessage.isNotEmpty
                                    ? admin.syncStatusMessage
                                    : 'Synced to Firebase!'),
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: admin.isSyncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Sync Now',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // KPI Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _buildKpiCard(
                context: context,
                title: 'ACTIVE NETWORKS',
                value: '${admin.cities.length} Cities',
                subtitle: 'Indian & Global',
                icon: Icons.location_city,
                color: Colors.blue,
              ),
              _buildKpiCard(
                context: context,
                title: 'LIVE DELAY ALERTS',
                value: '${admin.alerts.where((a) => a.isActive).length} Active',
                subtitle: 'Broadcasting to clients',
                icon: Icons.campaign,
                color: Colors.orange,
              ),
              _buildKpiCard(
                context: context,
                title: 'ADMOB ENGINE',
                value: admin.config.adsEnabled ? 'ENABLED' : 'PAUSED',
                subtitle: 'Freq: ${admin.config.interstitialFrequency} searches',
                icon: Icons.ads_click,
                color: admin.config.adsEnabled ? Colors.green : Colors.red,
              ),
              _buildKpiCard(
                context: context,
                title: 'PRIME PASS PRICE',
                value: '₹${admin.config.primePrice}',
                subtitle: '${admin.config.primeDiscountPercent}% Discount Active',
                icon: Icons.workspace_premium,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'ADMIN MANAGEMENT MODULES',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),

          // Menu Tiles
          _buildMenuTile(
            context: context,
            title: 'Global City & Network CMS',
            subtitle: 'Add Indian & International cities, lines & stations',
            icon: Icons.alt_route,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CityNetworkCmsScreen()),
            ),
          ),
          _buildMenuTile(
            context: context,
            title: 'Live Delay & Disruption Broadcaster',
            subtitle: 'Push instant technical delay notices and holiday timetables',
            icon: Icons.notification_important,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LiveDelayBroadcasterScreen()),
            ),
          ),
          _buildMenuTile(
            context: context,
            title: 'Dynamic Map Uploader',
            subtitle: 'Upload and assign SVG vector maps via Firebase Storage',
            icon: Icons.map,
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapUploaderScreen()),
            ),
          ),
          _buildMenuTile(
            context: context,
            title: 'Fare Matrix & Timetable Editor',
            subtitle: 'Configure distance slabs and first/last train timings',
            icon: Icons.calculate,
            color: Colors.deepPurple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FareScheduleEditorScreen()),
            ),
          ),
          _buildMenuTile(
            context: context,
            title: 'Monetization & AdMob Remote Config',
            subtitle: 'Killswitch, interstitial frequency & dynamic Prime pricing',
            icon: Icons.monetization_on,
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MonetizationControllerScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade600,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: onTap,
        ),
      ),
    );
  }
}
