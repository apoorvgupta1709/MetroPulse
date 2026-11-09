import 'dart:math';
import 'package:flutter/material.dart';
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

  const CrispVectorMap({
    super.key,
    required this.stations,
    required this.lines,
    this.activeRoute,
    this.isPrimeUser = false,
    this.highlightedStation,
    this.onStationTapped,
  });

  @override
  State<CrispVectorMap> createState() => _CrispVectorMapState();
}

class _CrispVectorMapState extends State<CrispVectorMap> {
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;

  @override
  void didUpdateWidget(covariant CrispVectorMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedStation != null &&
        widget.highlightedStation != oldWidget.highlightedStation) {
      _panToStation(widget.highlightedStation!);
    }
  }

  void _panToStation(Station station) {
    // Canvas coordinate mapping
    final pos = _mapGeoToCanvas(station.latitude, station.longitude);
    final targetX = -pos.dx * 1.5 + 200;
    final targetY = -pos.dy * 1.5 + 300;

    _transformationController.value = Matrix4.identity()
      ..translate(targetX, targetY)
      ..scale(1.5);
  }

  Offset _mapGeoToCanvas(double lat, double lng) {
    // Normalization mapping for high DPI canvas 2000x2000
    if (widget.stations.isEmpty) return const Offset(1000, 1000);

    double minLat = widget.stations.map((s) => s.latitude).reduce(min);
    double maxLat = widget.stations.map((s) => s.latitude).reduce(max);
    double minLng = widget.stations.map((s) => s.longitude).reduce(min);
    double maxLng = widget.stations.map((s) => s.longitude).reduce(max);

    if (maxLat - minLat == 0) maxLat += 0.01;
    if (maxLng - minLng == 0) maxLng += 0.01;

    final normX = (lng - minLng) / (maxLng - minLng);
    final normY = 1.0 - (lat - minLat) / (maxLat - minLat); // inverted Y for screen coords

    return Offset(150 + normX * 1700, 150 + normY * 1700);
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone();
    matrix.scale(1.3);
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone();
    matrix.scale(0.77);
    _transformationController.value = matrix;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // High DPI Vector Canvas
        InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.3,
          maxScale: 6.0,
          boundaryMargin: const EdgeInsets.all(1000),
          constrained: false,
          child: SizedBox(
            width: 2000,
            height: 2000,
            child: CustomPaint(
              painter: _VectorMetroMapPainter(
                stations: widget.stations,
                lines: widget.lines,
                activeRoute: widget.activeRoute,
                isPrimeUser: widget.isPrimeUser,
                highlightedStation: widget.highlightedStation,
                isDark: isDark,
              ),
            ),
          ),
        ),

        // Floating Zoom and Navigation Controls
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'zoom_in_btn',
                onPressed: _zoomIn,
                backgroundColor: Theme.of(context).cardColor,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoom_out_btn',
                onPressed: _zoomOut,
                backgroundColor: Theme.of(context).cardColor,
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'reset_zoom_btn',
                onPressed: _resetZoom,
                backgroundColor: Theme.of(context).cardColor,
                child: const Icon(Icons.center_focus_strong),
              ),
            ],
          ),
        ),

        // 4K Ultra-Crisp Badge
        Positioned(
          left: 16,
          bottom: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hd_outlined, color: Colors.cyanAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  '4K Vector Engine • Zero Blur',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VectorMetroMapPainter extends CustomPainter {
  final List<Station> stations;
  final List<MetroLine> lines;
  final RouteResult? activeRoute;
  final bool isPrimeUser;
  final Station? highlightedStation;
  final bool isDark;

  _VectorMetroMapPainter({
    required this.stations,
    required this.lines,
    required this.activeRoute,
    required this.isPrimeUser,
    required this.highlightedStation,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background Grid
    final bgPaint = Paint()..color = isDark ? const Color(0xFF12141A) : const Color(0xFFF8F9FA);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle Grid Lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.04)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 100) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Calculate station canvas positions
    final coords = <String, Offset>{};
    for (var s in stations) {
      coords[s.id] = _mapGeoToCanvas(s.latitude, s.longitude, size);
    }

    // 1. Draw Network Transit Lines
    for (var line in lines) {
      final linePaint = Paint()
        ..color = line.color.withOpacity(activeRoute != null ? 0.35 : 0.95)
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      bool started = false;

      for (var sId in line.stationIds) {
        final pos = coords[sId];
        if (pos != null) {
          if (!started) {
            path.moveTo(pos.dx, pos.dy);
            started = true;
          } else {
            path.lineTo(pos.dx, pos.dy);
          }
        }
      }
      canvas.drawPath(path, linePaint);
    }

    // 2. Draw Active Route Overlay (if Prime)
    if (activeRoute != null && isPrimeUser) {
      final routeGlowPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.4)
        ..strokeWidth = 18.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final routeCorePaint = Paint()
        ..color = Colors.cyanAccent
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final routePath = Path();
      for (int i = 0; i < activeRoute!.steps.length; i++) {
        final pos = coords[activeRoute!.steps[i].station.id];
        if (pos != null) {
          if (i == 0) {
            routePath.moveTo(pos.dx, pos.dy);
          } else {
            routePath.lineTo(pos.dx, pos.dy);
          }
        }
      }
      canvas.drawPath(routePath, routeGlowPaint);
      canvas.drawPath(routePath, routeCorePaint);
    }

    // 3. Draw Station Nodes & Labels
    for (var s in stations) {
      final pos = coords[s.id];
      if (pos == null) continue;

      final isHighlighted = highlightedStation?.id == s.id;
      final isInterchange = s.isInterchange;

      // Outer glow for interchange or highlighted
      if (isHighlighted || isInterchange) {
        final glowPaint = Paint()
          ..color = isHighlighted
              ? Colors.amber.withOpacity(0.5)
              : Colors.black.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, isHighlighted ? 22 : 14, glowPaint);
      }

      // Station Circle
      final nodePaint = Paint()
        ..color = isHighlighted
            ? Colors.amber
            : (isInterchange ? Colors.white : (isDark ? const Color(0xFF1E222D) : Colors.white))
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isHighlighted
            ? Colors.black
            : (isInterchange ? Colors.black87 : Colors.blueGrey)
        ..strokeWidth = isInterchange ? 4.0 : 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(pos, isInterchange ? 10 : 7, nodePaint);
      canvas.drawCircle(pos, isInterchange ? 10 : 7, borderPaint);

      // Station Text Label
      final textSpan = TextSpan(
        text: s.name,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: isInterchange ? 14 : 11,
          fontWeight: isInterchange ? FontWeight.w800 : FontWeight.w600,
          backgroundColor: (isDark ? Colors.black : Colors.white).withOpacity(0.6),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 180);

      textPainter.paint(canvas, Offset(pos.dx + 12, pos.dy - 8));
    }
  }

  Offset _mapGeoToCanvas(double lat, double lng, Size size) {
    if (stations.isEmpty) return Offset(size.width / 2, size.height / 2);

    double minLat = stations.map((s) => s.latitude).reduce(min);
    double maxLat = stations.map((s) => s.latitude).reduce(max);
    double minLng = stations.map((s) => s.longitude).reduce(min);
    double maxLng = stations.map((s) => s.longitude).reduce(max);

    if (maxLat - minLat == 0) maxLat += 0.01;
    if (maxLng - minLng == 0) maxLng += 0.01;

    final normX = (lng - minLng) / (maxLng - minLng);
    final normY = 1.0 - (lat - minLat) / (maxLat - minLat);

    return Offset(150 + normX * 1700, 150 + normY * 1700);
  }

  @override
  bool shouldRepaint(covariant _VectorMetroMapPainter oldDelegate) {
    return true;
  }
}
