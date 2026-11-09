import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/transit_provider.dart';
import '../services/location_service.dart';
import '../widgets/banner_ad_widget.dart';
import 'route_planner_screen.dart';

class MetroNearMeScreen extends StatefulWidget {
  const MetroNearMeScreen({super.key});

  @override
  State<MetroNearMeScreen> createState() => _MetroNearMeScreenState();
}

class _MetroNearMeScreenState extends State<MetroNearMeScreen> {
  bool _isLoading = true;
  List<StationDistance> _nearestList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndCalculate();
  }

  Future<void> _fetchLocationAndCalculate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final transit = Provider.of<TransitProvider>(context, listen: false);
    final pos = await LocationService.getCurrentPosition();

    if (pos == null) {
      // Fallback: Use city central coordinates if GPS denied or on desktop/emulator
      final lat = transit.activeCity.centerLatitude;
      final lng = transit.activeCity.centerLongitude;
      final list = LocationService.findNearestStations(
        userLat: lat,
        userLng: lng,
        stations: transit.stations,
      );
      setState(() {
        _isLoading = false;
        _nearestList = list;
        _errorMessage = 'GPS unavailable. Showing stations relative to city center.';
      });
      return;
    }

    final list = LocationService.findNearestStations(
      userLat: pos.latitude,
      userLng: pos.longitude,
      stations: transit.stations,
    );

    setState(() {
      _isLoading = false;
      _nearestList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transit = Provider.of<TransitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Metro Stations Near Me',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Location',
            onPressed: _fetchLocationAndCalculate,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.brown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.brown.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Acquiring GPS location...'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _nearestList.length,
                    itemBuilder: (context, index) {
                      final item = _nearestList[index];
                      final station = item.station;
                      final isClosest = index == 0;
                      final walkMins = (item.distanceKm * 12).round();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isClosest
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withOpacity(0.15),
                            width: isClosest ? 1.8 : 1,
                          ),
                          boxShadow: [
                            if (isClosest)
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isClosest
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.near_me,
                                color: isClosest ? Colors.white : Colors.grey.shade600,
                                size: 20,
                              ),
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
                                          station.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (isClosest)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'CLOSEST',
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
                                    '${item.distanceKm.toStringAsFixed(2)} km away • ~$walkMins mins walk',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                transit.setOrigin(station);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RoutePlannerScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Plan Route',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
}
