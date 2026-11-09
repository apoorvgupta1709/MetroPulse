import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/route_result.dart';
import '../models/station.dart';

class VerticalRouteTimeline extends StatelessWidget {
  final RouteResult route;

  const VerticalRouteTimeline({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: route.steps.length,
      itemBuilder: (context, index) {
        final step = route.steps[index];
        final isFirst = index == 0;
        final isLast = index == route.steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Time Column
            SizedBox(
              width: 50,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+${step.cumulativeMinutes}m',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isFirst || isLast
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Timeline Track Column
            Column(
              children: [
                // Top connector line
                Container(
                  width: 4,
                  height: 14,
                  color: isFirst ? Colors.transparent : step.line.color,
                ),
                // Station node indicator
                Container(
                  width: isFirst || isLast || step.isInterchangePoint ? 20 : 14,
                  height: isFirst || isLast || step.isInterchangePoint ? 20 : 14,
                  decoration: BoxDecoration(
                    color: isFirst || isLast ? Colors.white : step.line.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.line.color,
                      width: isFirst || isLast ? 5 : 2,
                    ),
                    boxShadow: [
                      if (step.isInterchangePoint)
                        BoxShadow(
                          color: step.line.color.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: step.isInterchangePoint
                      ? const Center(
                          child: Icon(Icons.sync_alt, size: 10, color: Colors.white),
                        )
                      : null,
                ),
                // Bottom connector line
                Container(
                  width: 4,
                  height: step.isInterchangePoint ? 50 : 28,
                  color: isLast ? Colors.transparent : step.line.color,
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Station Details Column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Station Name & Gate Button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.station.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: isFirst || isLast || step.isInterchangePoint
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isFirst || isLast
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                        ),
                        if (step.station.gates.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.door_sliding_outlined, size: 18),
                            tooltip: 'Exit Gates & Landmarks',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              _showGateInfoDialog(context, step.station);
                            },
                          ),
                      ],
                    ),

                    if (step.station.hindiName.isNotEmpty)
                      Text(
                        step.station.hindiName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),

                    // Direction & Platform Badge
                    if (isFirst || step.isInterchangePoint) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: step.line.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: step.line.color, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.subway, size: 12, color: step.line.color),
                                const SizedBox(width: 4),
                                Text(
                                  step.line.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: step.line.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (step.directionHeading != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                step.directionHeading!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.platformGuide ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    // Interchange Callout Box
                    if (step.isInterchangePoint && step.nextLine != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade400),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.transfer_within_a_station,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Change here to ${step.nextLine!.name} (~5 min transfer)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showGateInfoDialog(BuildContext context, Station station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${station.name} - Exits & Gates',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...station.gates.map((g) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          g.gateNumber,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          g.landmark,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
