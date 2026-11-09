import 'package:flutter/material.dart';
import '../models/admin_config.dart';

class AdminCity {
  String id;
  String name;
  String currency;
  String country;
  int linesCount;
  int stationsCount;
  String mapStatus;

  AdminCity({
    required this.id,
    required this.name,
    required this.currency,
    required this.country,
    required this.linesCount,
    required this.stationsCount,
    this.mapStatus = '4K Vector Active',
  });
}

class AdminAlert {
  String id;
  String cityName;
  String lineName;
  String title;
  String severity; // Normal, Delay, Maintenance
  DateTime time;
  bool isActive;

  AdminAlert({
    required this.id,
    required this.cityName,
    required this.lineName,
    required this.title,
    required this.severity,
    required this.time,
    this.isActive = true,
  });
}

class AdminControlProvider extends ChangeNotifier {
  final MonetizationConfig _config = MonetizationConfig();

  final List<AdminCity> _cities = [
    AdminCity(id: 'delhi_ncr', name: 'Delhi NCR', currency: '₹', country: 'India', linesCount: 12, stationsCount: 288),
    AdminCity(id: 'mumbai', name: 'Mumbai Metro', currency: '₹', country: 'India', linesCount: 3, stationsCount: 43),
    AdminCity(id: 'bengaluru', name: 'Bengaluru Namma Metro', currency: '₹', country: 'India', linesCount: 2, stationsCount: 66),
    AdminCity(id: 'hyderabad', name: 'Hyderabad Metro', currency: '₹', country: 'India', linesCount: 3, stationsCount: 57),
    AdminCity(id: 'kolkata', name: 'Kolkata Metro', currency: '₹', country: 'India', linesCount: 4, stationsCount: 50),
    AdminCity(id: 'chennai', name: 'Chennai Metro', currency: '₹', country: 'India', linesCount: 2, stationsCount: 41),
    AdminCity(id: 'pune', name: 'Pune Metro', currency: '₹', country: 'India', linesCount: 2, stationsCount: 30),
    AdminCity(id: 'ahmedabad', name: 'Ahmedabad Metro', currency: '₹', country: 'India', linesCount: 2, stationsCount: 32),
    AdminCity(id: 'kochi', name: 'Kochi Metro', currency: '₹', country: 'India', linesCount: 1, stationsCount: 25),
    AdminCity(id: 'jaipur', name: 'Jaipur Metro', currency: '₹', country: 'India', linesCount: 1, stationsCount: 11),
    AdminCity(id: 'dubai', name: 'Dubai Metro', currency: 'AED', country: 'UAE', linesCount: 2, stationsCount: 53),
    AdminCity(id: 'singapore', name: 'Singapore MRT', currency: 'S\$', country: 'Singapore', linesCount: 6, stationsCount: 134),
    AdminCity(id: 'london', name: 'London Underground', currency: '£', country: 'UK', linesCount: 11, stationsCount: 272),
  ];

  final List<AdminAlert> _alerts = [
    AdminAlert(
      id: 'alt_1',
      cityName: 'Delhi NCR',
      lineName: 'Yellow Line',
      title: 'Crowd regulation at Rajiv Chowk & Kashmere Gate',
      severity: 'Normal',
      time: DateTime.now().subtract(const Duration(minutes: 20)),
      isActive: true,
    ),
    AdminAlert(
      id: 'alt_2',
      cityName: 'Delhi NCR',
      lineName: 'Blue Line',
      title: 'Signaling software test near Yamuna Bank (+3m run time)',
      severity: 'Delay',
      time: DateTime.now().subtract(const Duration(minutes: 45)),
      isActive: true,
    ),
  ];

  MonetizationConfig get config => _config;
  List<AdminCity> get cities => _cities;
  List<AdminAlert> get alerts => _alerts;

  // Toggle AdMob Killswitch
  void toggleAds(bool enabled) {
    _config.adsEnabled = enabled;
    notifyListeners();
  }

  // Set Interstitial frequency
  void setInterstitialFrequency(int count) {
    _config.interstitialFrequency = count;
    notifyListeners();
  }

  // Update Dynamic Prime Pricing
  void updatePrimePricing({
    required int price,
    required int originalPrice,
    required int discountPercent,
    required int countdownHours,
  }) {
    _config.primePrice = price;
    _config.primeOriginalPrice = originalPrice;
    _config.primeDiscountPercent = discountPercent;
    _config.countdownHours = countdownHours;
    notifyListeners();
  }

  // Add / Edit Service Alert
  void broadcastAlert({
    required String cityName,
    required String lineName,
    required String title,
    required String severity,
  }) {
    _alerts.insert(
      0,
      AdminAlert(
        id: 'alt_${DateTime.now().millisecondsSinceEpoch}',
        cityName: cityName,
        lineName: lineName,
        title: title,
        severity: severity,
        time: DateTime.now(),
        isActive: true,
      ),
    );
    notifyListeners();
  }

  void toggleAlertStatus(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index].isActive = !_alerts[index].isActive;
      notifyListeners();
    }
  }

  void deleteAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // Add new city network
  void addCity({
    required String name,
    required String currency,
    required String country,
  }) {
    final id = name.toLowerCase().replaceAll(' ', '_');
    _cities.add(AdminCity(
      id: id,
      name: name,
      currency: currency,
      country: country,
      linesCount: 1,
      stationsCount: 10,
    ));
    notifyListeners();
  }
}
