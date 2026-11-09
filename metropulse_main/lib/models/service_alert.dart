enum AlertSeverity { normal, moderate, critical }

class ServiceAlert {
  final String id;
  final String cityId;
  final String lineId;
  final String lineName;
  final String headline;
  final String details;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isActive;

  const ServiceAlert({
    required this.id,
    required this.cityId,
    required this.lineId,
    required this.lineName,
    required this.headline,
    required this.details,
    required this.severity,
    required this.timestamp,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityId': cityId,
      'lineId': lineId,
      'lineName': lineName,
      'headline': headline,
      'details': details,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory ServiceAlert.fromMap(Map<String, dynamic> map) {
    return ServiceAlert(
      id: map['id'] ?? '',
      cityId: map['cityId'] ?? '',
      lineId: map['lineId'] ?? '',
      lineName: map['lineName'] ?? '',
      headline: map['headline'] ?? '',
      details: map['details'] ?? '',
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => AlertSeverity.moderate,
      ),
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }
}
