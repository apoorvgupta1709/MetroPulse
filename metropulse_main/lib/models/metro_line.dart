import 'package:flutter/material.dart';

class MetroLine {
  final String id;
  final String cityId;
  final String name;
  final String code; // e.g. "YL", "BL", "RD"
  final String colorHex;
  final String firstTrain;
  final String lastTrain;
  final int frequencyMinutes;
  final List<String> stationIds;
  final String startStationName;
  final String endStationName;

  const MetroLine({
    required this.id,
    required this.cityId,
    required this.name,
    required this.code,
    required this.colorHex,
    required this.firstTrain,
    required this.lastTrain,
    required this.frequencyMinutes,
    required this.stationIds,
    required this.startStationName,
    required this.endStationName,
  });

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityId': cityId,
      'name': name,
      'code': code,
      'colorHex': colorHex,
      'firstTrain': firstTrain,
      'lastTrain': lastTrain,
      'frequencyMinutes': frequencyMinutes,
      'stationIds': stationIds,
      'startStationName': startStationName,
      'endStationName': endStationName,
    };
  }

  factory MetroLine.fromMap(Map<String, dynamic> map) {
    return MetroLine(
      id: map['id'] ?? '',
      cityId: map['cityId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      colorHex: map['colorHex'] ?? '#2196F3',
      firstTrain: map['firstTrain'] ?? '05:30 AM',
      lastTrain: map['lastTrain'] ?? '11:30 PM',
      frequencyMinutes: map['frequencyMinutes'] ?? 4,
      stationIds: List<String>.from(map['stationIds'] ?? []),
      startStationName: map['startStationName'] ?? '',
      endStationName: map['endStationName'] ?? '',
    );
  }
}
