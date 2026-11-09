import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/station.dart';
import '../providers/monetization_provider.dart';
import '../providers/transit_provider.dart';
import '../widgets/crisp_vector_map.dart';
import 'prime_paywall_screen.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  Station? _highlightedStation;
  bool _overlayActiveRoute = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transit = Provider.of<TransitProvider>(context);
    final monetization = Provider.of<MonetizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${transit.activeCity.name} Map',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        actions: [
          // Route Overlay Toggle
          IconButton(
            icon: Icon(
              _overlayActiveRoute ? Icons.route : Icons.route_outlined,
              color: _overlayActiveRoute ? Colors.amber : null,
            ),
            tooltip: 'Toggle Route Highlight (Prime)',
            onPressed: () {
              if (!monetization.isPro) {
                // Prime teaser prompt
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Route Highlight Overlay is a Prime feature!'),
                    action: SnackBarAction(
                      label: 'Unlock',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrimePaywallScreen()),
                        );
                      },
                    ),
                  ),
                );
                return;
              }
              setState(() {
                _overlayActiveRoute = !_overlayActiveRoute;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 4K Ultra-Crisp Vector Map Engine
          CrispVectorMap(
            stations: transit.stations,
            lines: transit.lines,
            activeRoute: _overlayActiveRoute ? transit.fastestRoute : null,
            isPrimeUser: monetization.isPro,
            highlightedStation: _highlightedStation,
            onStationTapped: (station) {
              setState(() {
                _highlightedStation = station;
              });
            },
          ),

          // Search-to-locate top bar
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Autocomplete<Station>(
                displayStringForOption: (s) => s.name,
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Station>.empty();
                  }
                  return transit.searchStations(textEditingValue.text);
                },
                onSelected: (Station selection) {
                  setState(() {
                    _highlightedStation = selection;
                  });
                  FocusScope.of(context).unfocus();
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search a station to locate...',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _highlightedStation != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
