class City {
  final String id;
  final String name;
  final String stateOrCountry;
  final String currencySymbol;
  final String country;
  final String rechargeUrl;
  final bool isInternational;
  final double centerLatitude;
  final double centerLongitude;

  const City({
    required this.id,
    required this.name,
    required this.stateOrCountry,
    required this.currencySymbol,
    required this.country,
    required this.rechargeUrl,
    this.isInternational = false,
    required this.centerLatitude,
    required this.centerLongitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'stateOrCountry': stateOrCountry,
      'currencySymbol': currencySymbol,
      'country': country,
      'rechargeUrl': rechargeUrl,
      'isInternational': isInternational,
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      stateOrCountry: map['stateOrCountry'] ?? '',
      currencySymbol: map['currencySymbol'] ?? '₹',
      country: map['country'] ?? 'India',
      rechargeUrl: map['rechargeUrl'] ?? '',
      isInternational: map['isInternational'] ?? false,
      centerLatitude: (map['centerLatitude'] as num?)?.toDouble() ?? 28.6139,
      centerLongitude: (map['centerLongitude'] as num?)?.toDouble() ?? 77.2090,
    );
  }
}
