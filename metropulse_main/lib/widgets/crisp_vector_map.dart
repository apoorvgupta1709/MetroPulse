import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/metro_line.dart';
import '../models/route_result.dart';
import '../models/station.dart';

class CrispVectorMap extends StatefulWidget {
  final String cityId;
  final String cityName;
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
    this.cityId = 'delhi_ncr',
    this.cityName = 'Delhi NCR Metro',
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

  static const double _canvasWidth = 3800.0;
  static const double _canvasHeight = 3200.0;

  // City-specific SVG assets
  static const Map<String, String> _citySvgAssets = {
    'delhi_ncr': 'assets/maps/delhi_metro_schematic.svg',
    'mumbai': 'assets/maps/mumbai_metro_schematic.svg',
    'bengaluru': 'assets/maps/bengaluru_metro_schematic.svg',
    'kolkata': 'assets/maps/kolkata_metro_schematic.svg',
    'hyderabad': 'assets/maps/hyderabad_metro_schematic.svg',
    'chennai': 'assets/maps/chennai_metro_schematic.svg',
  };

  // Station positions on schematic canvas (matching the authentic layout)
  static const Map<String, Offset> _schematicStationCoords = {
    // Delhi NCR Hubs
    'del_rajiv_chowk': Offset(1600, 1250),
    'del_kashmere_gate': Offset(1600, 750),
    'del_new_delhi': Offset(1600, 1120),
    'del_central_secretariat': Offset(1600, 1450),
    'del_dilli_haat_ina': Offset(1600, 1810),
    'del_aiims': Offset(1600, 1890),
    'del_hauz_khas': Offset(1600, 2040),
    'del_malviya_nagar': Offset(1600, 2130),
    'del_saket': Offset(1600, 2210),
    'del_qutab_minar': Offset(1600, 2290),
    'del_sikanderpur': Offset(1600, 2720),
    'del_millennium_city_centre': Offset(1400, 2800),
    'del_samaypur_badli': Offset(1600, 220),
    'del_azadpur': Offset(1300, 470),
    'del_vishwa_vidyalaya': Offset(1600, 600),
    'del_chandni_chowk': Offset(1600, 920),
    'del_janakpuri_west': Offset(820, 1650),
    'del_dwarka_sec_21': Offset(380, 2250),
    'del_rajouri_garden': Offset(1020, 1430),
    'del_kirti_nagar': Offset(1200, 1330),
    'del_karol_bagh': Offset(1500, 1250),
    'del_mandi_house': Offset(1850, 1250),
    'del_yamuna_bank': Offset(2100, 1250),
    'del_mayur_vihar_1': Offset(2280, 1350),
    'del_botanical_garden': Offset(2700, 1550),
    'del_noida_sec_18': Offset(2640, 1550),
    'del_noida_sec_52': Offset(2980, 1550),
    'del_noida_sec_51': Offset(2980, 1680),
    'del_noida_electronic_city': Offset(3380, 1550),
    'del_rithala': Offset(450, 750),
    'del_netaji_subhash_place': Offset(980, 750),
    'del_inderlok': Offset(1220, 750),
    'del_welcome': Offset(2050, 750),
    'del_shaheed_sthal': Offset(2650, 775),
    'del_terminal_1_igi_airport': Offset(950, 2100),
    'del_munirka': Offset(1270, 2130),
    'del_greater_kailash': Offset(1920, 2040),
    'del_kalkaji_mandir': Offset(2100, 2020),
    'del_lajpat_nagar': Offset(1940, 1760),
    'del_anand_vihar_isbt': Offset(2540, 960),
    'del_vaishali': Offset(2780, 960),
    'del_majlis_park': Offset(1450, 360),
    'del_shiv_vihar': Offset(2300, 300),
    'del_shivaji_stadium': Offset(1480, 1280),
    'del_dhaula_kuan': Offset(1230, 1740),
    'del_delhi_aerocity': Offset(990, 2210),
    'del_igi_airport_t3': Offset(780, 2350),
    'del_raja_nahar_singh': Offset(2100, 2950),

    // Mumbai Hubs
    'mum_andheri': Offset(1500, 1300),
    'mum_dn_nagar': Offset(900, 1300),
    'mum_marol_naka': Offset(2650, 1300),
    'mum_ghatkopar': Offset(2850, 1850),
    'mum_western_express': Offset(1800, 1300),

    // Bengaluru Hubs
    'blr_majestic': Offset(1600, 1300),
    'blr_mg_road': Offset(2100, 1300),
    'blr_indiranagar': Offset(2350, 1300),
    'blr_whitefield': Offset(3000, 1300),

    // Kolkata Hubs
    'kol_esplanade': Offset(1600, 1300),
    'kol_howrah_rly': Offset(950, 1300),
    'kol_sector_v': Offset(2900, 1300),

    // Hyderabad Hubs
    'hyd_ameerpet': Offset(1400, 1300),
    'hyd_mgbs': Offset(2200, 1900),
    'hyd_parade_ground': Offset(2000, 1100),

    // Chennai Hubs
    'che_central': Offset(1900, 1300),
    'che_alandur': Offset(1050, 2200),
    'che_airport': Offset(800, 2400),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      recenterMap(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant CrispVectorMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cityId != oldWidget.cityId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        recenterMap(animate: true);
      });
    } else if (widget.highlightedStation != null &&
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

  Offset _getCityCenterHub(String cityId) {
    switch (cityId) {
      case 'delhi_ncr':
        return const Offset(1600, 1250); // Rajiv Chowk
      case 'mumbai':
        return const Offset(1500, 1300); // Andheri Hub
      case 'bengaluru':
        return const Offset(1600, 1300); // Kempegowda Majestic
      case 'kolkata':
        return const Offset(1600, 1300); // Esplanade Hub
      case 'hyderabad':
        return const Offset(1400, 1300); // Ameerpet Hub
      case 'chennai':
        return const Offset(1900, 1300); // Chennai Central
      default:
        return const Offset(1600, 1300);
    }
  }

  Offset getStationCanvasOffset(Station station) {
    if (_schematicStationCoords.containsKey(station.id)) {
      return _schematicStationCoords[station.id]!;
    }

    if (widget.stations.isEmpty) return _getCityCenterHub(widget.cityId);

    double minLat = widget.stations.map((s) => s.latitude).reduce(min);
    double maxLat = widget.stations.map((s) => s.latitude).reduce(max);
    double minLng = widget.stations.map((s) => s.longitude).reduce(min);
    double maxLng = widget.stations.map((s) => s.longitude).reduce(max);

    if (maxLat - minLat == 0) maxLat += 0.01;
    if (maxLng - minLng == 0) maxLng += 0.01;

    final normX = (station.longitude - minLng) / (maxLng - minLng);
    final normY = 1.0 - (station.latitude - minLat) / (maxLat - minLat);

    return Offset(500 + normX * 2600, 400 + normY * 2200);
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
    final centerPoint = _getCityCenterHub(widget.cityId);
    const defaultScale = 0.52;

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
    final svgAsset = _citySvgAssets[widget.cityId];

    return Stack(
      children: [
        // 1. High-Precision Vector Canvas (Zero Blur at any zoom)
        InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.22,
          maxScale: 8.0,
          boundaryMargin: const EdgeInsets.all(1800),
          constrained: false,
          child: GestureDetector(
            onTapUp: _handleCanvasTap,
            child: SizedBox(
              width: _canvasWidth,
              height: _canvasHeight,
              child: Stack(
                children: [
                  // City-Specific Crisp Vector Schematic
                  if (svgAsset != null)
                    SvgPicture.asset(
                      svgAsset,
                      width: _canvasWidth,
                      height: _canvasHeight,
                      fit: BoxFit.fill,
                    )
                  else
                    // Dynamic Canvas Fallback for any other city
                    CustomPaint(
                      size: const Size(_canvasWidth, _canvasHeight),
                      painter: _DynamicCitySchematicPainter(
                        stations: widget.stations,
                        lines: widget.lines,
                        cityName: widget.cityName,
                        getStationOffset: getStationCanvasOffset,
                      ),
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
              _buildCircularActionButton(
                icon: Icons.my_location,
                tooltip: 'Recenter Map',
                onPressed: () => recenterMap(animate: true),
              ),
              const SizedBox(height: 12),
              _buildCircularActionButton(
                icon: Icons.add,
                tooltip: 'Zoom In',
                onPressed: zoomIn,
              ),
              const SizedBox(height: 12),
              _buildCircularActionButton(
                icon: Icons.remove,
                tooltip: 'Zoom Out',
                onPressed: zoomOut,
              ),
              const SizedBox(height: 12),
              _buildCircularActionButton(
                icon: widget.isFullscreen ? Icons.fullscreen_exit : Icons.open_in_full,
                tooltip: widget.isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
                onPressed: widget.onToggleFullscreen,
              ),
            ],
          ),
        ),

        // 4. Attribution Badge
        Positioned(
          left: 16,
          bottom: 12,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                'Made with ❤️ by Apoorv',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
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

class _DynamicCitySchematicPainter extends CustomPainter {
  final List<Station> stations;
  final List<MetroLine> lines;
  final String cityName;
  final Offset Function(Station) getStationOffset;

  _DynamicCitySchematicPainter({
    required this.stations,
    required this.lines,
    required this.cityName,
    required this.getStationOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Pure white backdrop
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    final stationMap = {for (var s in stations) s.id: s};

    // Draw lines
    for (var line in lines) {
      Color lineColor = Colors.blue;
      try {
        final hex = line.colorHex.replaceAll('#', '');
        lineColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}

      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      bool isFirst = true;

      for (var sid in line.stationIds) {
        final s = stationMap[sid];
        if (s != null) {
          final pos = getStationOffset(s);
          if (isFirst) {
            path.moveTo(pos.dx, pos.dy);
            isFirst = false;
          } else {
            path.lineTo(pos.dx, pos.dy);
          }
        }
      }

      if (!isFirst) {
        canvas.drawPath(path, linePaint);
      }
    }

    // Draw stations
    for (var s in stations) {
      final pos = getStationOffset(s);

      if (s.isInterchange) {
        canvas.drawCircle(
          pos,
          12,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          pos,
          12,
          Paint()
            ..color = const Color(0xFF0F172A)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
        canvas.drawCircle(
          pos,
          5,
          Paint()..color = const Color(0xFF0F172A),
        );
      } else {
        canvas.drawCircle(
          pos,
          5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          pos,
          5,
          Paint()
            ..color = const Color(0xFF1E293B)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }

      // Draw Station Label
      final textSpan = TextSpan(
        text: '${s.hindiName.isNotEmpty ? "${s.hindiName}\n" : ""}${s.name}',
        style: TextStyle(
          color: const Color(0xFF0F172A),
          fontSize: s.isInterchange ? 13 : 11,
          fontWeight: s.isInterchange ? FontWeight.w800 : FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx + 14, pos.dy - 10));
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicCitySchematicPainter oldDelegate) => true;
}
