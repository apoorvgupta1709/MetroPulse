import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/metro_line.dart';
import '../models/route_result.dart';
import '../models/station.dart';

class CrispVectorMap extends StatefulWidget {
  final List<Station> stations;
  final List<MetroLine> lines;
  final RouteResult? activeRoute;
  final bool isPrimeUser;
  final Station? highlightedStation;
  final Function(Station)? onStationTapped;
  final VoidCallback? onToggle4K;
  final bool is4KActive;
  final VoidCallback? onToggleFullscreen;
  final bool isFullscreen;

  const CrispVectorMap({
    super.key,
    required this.stations,
    required this.lines,
    this.activeRoute,
    this.isPrimeUser = false,
    this.highlightedStation,
    this.onStationTapped,
    this.onToggle4K,
    this.is4KActive = true,
    this.onToggleFullscreen,
    this.isFullscreen = false,
  });

  @override
  State<CrispVectorMap> createState() => CrispVectorMapState();
}

class CrispVectorMapState extends State<CrispVectorMap> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  static const double _canvasWidth = 3200.0;
  static const double _canvasHeight = 2600.0;

  // Station positions on schematic canvas (matching the authentic DMRC layout)
  static const Map<String, Offset> _schematicStationCoords = {
    'del_rajiv_chowk': Offset(1400, 1050),
    'del_kashmere_gate': Offset(1400, 650),
    'del_new_delhi': Offset(1400, 880),
    'del_central_secretariat': Offset(1400, 1200),
    'del_dilli_haat_ina': Offset(1400, 1380),
    'del_aiims': Offset(1400, 1480),
    'del_hauz_khas': Offset(1400, 1600),
    'del_malviya_nagar': Offset(1400, 1750),
    'del_saket': Offset(1400, 1880),
    'del_qutab_minar': Offset(1400, 2000),
    'del_sikanderpur': Offset(1400, 2150),
    'del_huda_city_centre': Offset(1400, 2350),
    'del_samaypur_badli': Offset(1400, 150),
    'del_azadpur': Offset(1100, 380),
    'del_vishwa_vidyalaya': Offset(1400, 480),
    'del_chandni_chowk': Offset(1400, 780),

    'del_janakpuri_west': Offset(750, 1450),
    'del_dwarka_mor': Offset(600, 1700),
    'del_dwarka_sec_21': Offset(450, 1950),
    'del_rajouri_garden': Offset(950, 1250),
    'del_kirti_nagar': Offset(1150, 1150),
    'del_karol_bagh': Offset(1300, 1050),
    'del_mandi_house': Offset(1600, 1050),
    'del_yamuna_bank': Offset(1800, 1050),
    'del_mayur_vihar_1': Offset(1950, 1150),
    'del_botanical_garden': Offset(2150, 1350),
    'del_noida_sec_18': Offset(2300, 1400),
    'del_noida_sec_52': Offset(2550, 1450),
    'del_noida_electronic_city': Offset(2750, 1450),

    'del_rithala': Offset(400, 650),
    'del_netaji_subhash_place': Offset(800, 650),
    'del_inderlok': Offset(1050, 650),
    'del_welcome': Offset(2150, 650),
    'del_shaheed_sthal': Offset(2600, 650),

    'del_igi_airport_t1': Offset(850, 1650),
    'del_munirka': Offset(1200, 1600),
    'del_greater_kailash': Offset(1600, 1680),
    'del_kalkaji_mandir': Offset(1750, 1700),

    'del_lajpat_nagar': Offset(1750, 1550),
    'del_anand_vihar_isbt': Offset(2350, 850),
    'del_vaishali': Offset(2550, 850),
    'del_majlis_park': Offset(1300, 280),
    'del_shiv_vihar': Offset(1800, 350),

    'del_shivaji_stadium': Offset(1320, 1000),
    'del_dhaula_kuan': Offset(1000, 1500),
    'del_delhi_aerocity': Offset(750, 1800),
    'del_igi_airport_t3': Offset(600, 1900),
    'del_raja_nahar_singh': Offset(1800, 2450),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });

    // Initial view centered on central hub: Rajiv Chowk
    WidgetsBinding.instance.addPostFrameCallback((_) {
      recenterMap(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant CrispVectorMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedStation != null &&
        widget.highlightedStation != oldWidget.highlightedStation) {
      panToStation(widget.highlightedStation!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  Offset getStationCanvasOffset(Station station) {
    if (_schematicStationCoords.containsKey(station.id)) {
      return _schematicStationCoords[station.id]!;
    }

    // Normalized geo projection fallback
    if (widget.stations.isEmpty) return const Offset(1400, 1050);

    double minLat = widget.stations.map((s) => s.latitude).reduce(min);
    double maxLat = widget.stations.map((s) => s.latitude).reduce(max);
    double minLng = widget.stations.map((s) => s.longitude).reduce(min);
    double maxLng = widget.stations.map((s) => s.longitude).reduce(max);

    if (maxLat - minLat == 0) maxLat += 0.01;
    if (maxLng - minLng == 0) maxLng += 0.01;

    final normX = (station.longitude - minLng) / (maxLng - minLng);
    final normY = 1.0 - (station.latitude - minLat) / (maxLat - minLat);

    return Offset(400 + normX * 2400, 300 + normY * 2000);
  }

  void panToStation(Station station, {double targetScale = 1.8}) {
    final pos = getStationCanvasOffset(station);
    final screenSize = MediaQuery.of(context).size;

    final targetX = -pos.dx * targetScale + (screenSize.width / 2);
    final targetY = -pos.dy * targetScale + (screenSize.height / 2.5);

    final targetMatrix = Matrix4.identity()
      ..translate(targetX, targetY)
      ..scale(targetScale);

    _animateToMatrix(targetMatrix);
  }

  void recenterMap({bool animate = true}) {
    final screenSize = MediaQuery.of(context).size;
    const centerPoint = Offset(1400, 1050); // Rajiv Chowk
    const defaultScale = 0.55;

    final targetX = -centerPoint.dx * defaultScale + (screenSize.width / 2);
    final targetY = -centerPoint.dy * defaultScale + (screenSize.height / 2.2);

    final targetMatrix = Matrix4.identity()
      ..translate(targetX, targetY)
      ..scale(defaultScale);

    if (animate) {
      _animateToMatrix(targetMatrix);
    } else {
      _transformationController.value = targetMatrix;
    }
  }

  void zoomIn() {
    final currentMatrix = _transformationController.value;
    final scale = currentMatrix.getMaxScaleOnAxis() * 1.35;
    if (scale > 7.0) return;

    final screenSize = MediaQuery.of(context).size;
    final center = Offset(screenSize.width / 2, screenSize.height / 2);

    final targetMatrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(1.35)
      ..translate(-center.dx, -center.dy)
      ..multiply(currentMatrix);

    _animateToMatrix(targetMatrix);
  }

  void zoomOut() {
    final currentMatrix = _transformationController.value;
    final scale = currentMatrix.getMaxScaleOnAxis() * 0.74;
    if (scale < 0.25) return;

    final screenSize = MediaQuery.of(context).size;
    final center = Offset(screenSize.width / 2, screenSize.height / 2);

    final targetMatrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(0.74)
      ..translate(-center.dx, -center.dy)
      ..multiply(currentMatrix);

    _animateToMatrix(targetMatrix);
  }

  void _animateToMatrix(Matrix4 target) {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: target,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    _animationController.forward(from: 0.0);
  }

  void _handleCanvasTap(TapUpDetails details) {
    final localPos = details.localPosition;
    // Find closest station within 45px hit radius
    Station? closest;
    double minDistance = 45.0;

    for (var s in widget.stations) {
      final sOffset = getStationCanvasOffset(s);
      final dist = (sOffset - localPos).distance;
      if (dist < minDistance) {
        minDistance = dist;
        closest = s;
      }
    }

    if (closest != null && widget.onStationTapped != null) {
      widget.onStationTapped!(closest);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. High-Precision Vector Canvas (Zero Blur at any zoom)
        InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.25,
          maxScale: 8.0,
          boundaryMargin: const EdgeInsets.all(1600),
          constrained: false,
          child: GestureDetector(
            onTapUp: _handleCanvasTap,
            child: SizedBox(
              width: _canvasWidth,
              height: _canvasHeight,
              child: Stack(
                children: [
                  // Beautiful Schematic Delhi Metro SVG Map Artwork
                  SvgPicture.asset(
                    'assets/maps/delhi_metro_schematic.svg',
                    width: _canvasWidth,
                    height: _canvasHeight,
                    fit: BoxFit.fill,
                  ),

                  // Active Route Highlight Overlay (Prime Commuter Feature)
                  if (widget.activeRoute != null && widget.isPrimeUser)
                    CustomPaint(
                      size: const Size(_canvasWidth, _canvasHeight),
                      painter: _RouteOverlayPainter(
                        activeRoute: widget.activeRoute!,
                        getStationOffset: getStationCanvasOffset,
                      ),
                    ),

                  // Highlighted Station Pulsing Pin Marker
                  if (widget.highlightedStation != null)
                    _buildPulsingStationMarker(widget.highlightedStation!),
                ],
              ),
            ),
          ),
        ),

        // 2. Floating "4K" Ultra-Crisp Badge (Top Left matching screenshot)
        Positioned(
          top: 14,
          left: 16,
          child: GestureDetector(
            onTap: widget.onToggle4K ?? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('4K Ultra-Crisp Vector Engine Active • 0% Blur'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.4), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search, color: Colors.cyanAccent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '4K',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. Floating Control Buttons Stack (Right Column matching screenshot)
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Target / Recenter Button
              _buildCircularActionButton(
                icon: Icons.my_location,
                tooltip: 'Recenter Map',
                onPressed: () => recenterMap(animate: true),
              ),
              const SizedBox(height: 12),

              // Zoom In Button (+)
              _buildCircularActionButton(
                icon: Icons.add,
                tooltip: 'Zoom In',
                onPressed: zoomIn,
              ),
              const SizedBox(height: 12),

              // Zoom Out Button (-)
              _buildCircularActionButton(
                icon: Icons.remove,
                tooltip: 'Zoom Out',
                onPressed: zoomOut,
              ),
              const SizedBox(height: 12),

              // Fullscreen Toggle Button (⤢)
              _buildCircularActionButton(
                icon: widget.isFullscreen ? Icons.fullscreen_exit : Icons.open_in_full,
                tooltip: widget.isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
                onPressed: widget.onToggleFullscreen,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, color: const Color(0xFF1E293B), size: 22),
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildPulsingStationMarker(Station station) {
    final pos = getStationCanvasOffset(station);

    return Positioned(
      left: pos.dx - 40,
      top: pos.dy - 70,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                station.name,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 16,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: const Icon(Icons.location_on, color: Colors.black87, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteOverlayPainter extends CustomPainter {
  final RouteResult activeRoute;
  final Offset Function(Station) getStationOffset;

  _RouteOverlayPainter({
    required this.activeRoute,
    required this.getStationOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (activeRoute.steps.isEmpty) return;

    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.5)
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final corePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < activeRoute.steps.length; i++) {
      final pos = getStationOffset(activeRoute.steps[i].station);
      if (i == 0) {
        path.moveTo(pos.dx, pos.dy);
      } else {
        path.lineTo(pos.dx, pos.dy);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, corePaint);

    // Origin and Destination Markers
    final originPos = getStationOffset(activeRoute.steps.first.station);
    final destPos = getStationOffset(activeRoute.steps.last.station);

    final startPin = Paint()..color = Colors.greenAccent;
    final endPin = Paint()..color = Colors.deepOrangeAccent;

    canvas.drawCircle(originPos, 16, startPin);
    canvas.drawCircle(destPos, 16, endPin);
  }

  @override
  bool shouldRepaint(covariant _RouteOverlayPainter oldDelegate) => true;
}
