import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_control_provider.dart';

class LiveDelayBroadcasterScreen extends StatefulWidget {
  const LiveDelayBroadcasterScreen({super.key});

  @override
  State<LiveDelayBroadcasterScreen> createState() => _LiveDelayBroadcasterScreenState();
}

class _LiveDelayBroadcasterScreenState extends State<LiveDelayBroadcasterScreen> {
  final _headlineController = TextEditingController();
  String _selectedCity = 'Delhi NCR';
  String _selectedLine = 'Yellow Line';
  String _severity = 'Moderate Delay';

  @override
  void dispose() {
    _headlineController.dispose();
    super.dispose();
  }

  void _broadcastNewAlert() {
    if (_headlineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an alert headline')),
      );
      return;
    }

    Provider.of<AdminControlProvider>(context, listen: false).broadcastAlert(
      cityName: _selectedCity,
      lineName: _selectedLine,
      title: _headlineController.text.trim(),
      severity: _severity,
    );

    _headlineController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disruption alert broadcasted live to all client apps!'),
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
          'Live Delay Broadcaster',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Broadcast Composer Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.campaign, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'COMPOSE LIVE TRANSIT ALERT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'Network City',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: ['Delhi NCR', 'Mumbai Metro', 'Bengaluru Namma Metro', 'Dubai Metro']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCity = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedLine,
                        decoration: const InputDecoration(
                          labelText: 'Metro Line',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: ['Yellow Line', 'Blue Line', 'Red Line', 'Magenta Line', 'Pink Line', 'Airport Express']
                            .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedLine = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _headlineController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alert Headline & Commuter Guidance',
                    hintText: 'e.g. Yellow line 10-min technical delay between Rajiv Chowk and AIIMS.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _severity,
                  decoration: const InputDecoration(
                    labelText: 'Alert Severity',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  items: ['Normal Service Info', 'Moderate Delay', 'Critical Disruption']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _severity = val);
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _broadcastNewAlert,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      'Push Instant Alert to Clients',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'ACTIVE & HISTORICAL BROADCASTS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),

          ...admin.alerts.map((alert) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: alert.isActive ? Colors.orange.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    alert.isActive ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                    color: alert.isActive ? Colors.orange : Colors.grey,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${alert.cityName} • ${alert.lineName}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: alert.isActive ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                alert.isActive ? 'ACTIVE' : 'MUTED',
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
                          alert.title,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(alert.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline),
                    tooltip: alert.isActive ? 'Pause Broadcast' : 'Resume Broadcast',
                    onPressed: () => admin.toggleAlertStatus(alert.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Delete Alert',
                    onPressed: () => admin.deleteAlert(alert.id),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
