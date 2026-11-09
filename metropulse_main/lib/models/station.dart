class StationGate {
  final String gateNumber;
  final String landmark;
  final bool hasWheelchairAccess;

  const StationGate({
    required this.gateNumber,
    required this.landmark,
    this.hasWheelchairAccess = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'gateNumber': gateNumber,
      'landmark': landmark,
      'hasWheelchairAccess': hasWheelchairAccess,
    };
  }

  factory StationGate.fromMap(Map<String, dynamic> map) {
    return StationGate(
      gateNumber: map['gateNumber'] ?? '',
      landmark: map['landmark'] ?? '',
      hasWheelchairAccess: map['hasWheelchairAccess'] ?? true,
    );
  }
}

class StationFacilities {
  final bool hasParking;
  final bool hasEscalator;
  final bool hasElevator;
  final bool hasAtm;
  final bool hasRestroom;
  final bool hasWifi;

  const StationFacilities({
    this.hasParking = true,
    this.hasEscalator = true,
    this.hasElevator = true,
    this.hasAtm = true,
    this.hasRestroom = true,
    this.hasWifi = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'hasParking': hasParking,
      'hasEscalator': hasEscalator,
      'hasElevator': hasElevator,
      'hasAtm': hasAtm,
      'hasRestroom': hasRestroom,
      'hasWifi': hasWifi,
    };
  }

  factory StationFacilities.fromMap(Map<String, dynamic> map) {
    return StationFacilities(
      hasParking: map['hasParking'] ?? true,
      hasEscalator: map['hasEscalator'] ?? true,
      hasElevator: map['hasElevator'] ?? true,
      hasAtm: map['hasAtm'] ?? true,
      hasRestroom: map['hasRestroom'] ?? true,
      hasWifi: map['hasWifi'] ?? true,
    );
  }
}

class Station {
  final String id;
  final String cityId;
  final String name;
  final String hindiName;
  final List<String> lineIds;
  final bool isInterchange;
  final double latitude;
  final double longitude;
  final List<StationGate> gates;
  final StationFacilities facilities;
  final Map<String, String> platformDirections; // lineId -> Platform & direction text

  const Station({
    required this.id,
    required this.cityId,
    required this.name,
    this.hindiName = '',
    required this.lineIds,
    required this.isInterchange,
    required this.latitude,
    required this.longitude,
    required this.gates,
    required this.facilities,
    required this.platformDirections,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityId': cityId,
      'name': name,
      'hindiName': hindiName,
      'lineIds': lineIds,
      'isInterchange': isInterchange,
      'latitude': latitude,
      'longitude': longitude,
      'gates': gates.map((g) => g.toMap()).toList(),
      'facilities': facilities.toMap(),
      'platformDirections': platformDirections,
    };
  }

  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      id: map['id'] ?? '',
      cityId: map['cityId'] ?? '',
      name: map['name'] ?? '',
      hindiName: map['hindiName'] ?? '',
      lineIds: List<String>.from(map['lineIds'] ?? []),
      isInterchange: map['isInterchange'] ?? false,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      gates: (map['gates'] as List? ?? [])
          .map((g) => StationGate.fromMap(Map<String, dynamic>.from(g)))
          .toList(),
      facilities: StationFacilities.fromMap(
          Map<String, dynamic>.from(map['facilities'] ?? {})),
      platformDirections: Map<String, String>.from(map['platformDirections'] ?? {}),
    );
  }
}
