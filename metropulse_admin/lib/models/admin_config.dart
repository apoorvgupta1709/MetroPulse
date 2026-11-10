class MonetizationConfig {
  bool adsEnabled;
  int interstitialFrequency;
  int primePrice;
  int primeOriginalPrice;
  int primeDiscountPercent;
  int countdownHours;
  String razorpayKeyId;

  MonetizationConfig({
    this.adsEnabled = true,
    this.interstitialFrequency = 3,
    this.primePrice = 49,
    this.primeOriginalPrice = 149,
    this.primeDiscountPercent = 67,
    this.countdownHours = 6,
    this.razorpayKeyId = 'rzp_test_1DP5mmOlF5G5ag',
  });

  Map<String, dynamic> toMap() {
    return {
      'adsEnabled': adsEnabled,
      'interstitialFrequency': interstitialFrequency,
      'primePrice': primePrice,
      'primeOriginalPrice': primeOriginalPrice,
      'primeDiscountPercent': primeDiscountPercent,
      'countdownHours': countdownHours,
      'razorpayKeyId': razorpayKeyId,
    };
  }

  factory MonetizationConfig.fromMap(Map<String, dynamic> map) {
    return MonetizationConfig(
      adsEnabled: map['adsEnabled'] ?? true,
      interstitialFrequency: map['interstitialFrequency'] ?? 3,
      primePrice: map['primePrice'] ?? 49,
      primeOriginalPrice: map['primeOriginalPrice'] ?? 149,
      primeDiscountPercent: map['primeDiscountPercent'] ?? 67,
      countdownHours: map['countdownHours'] ?? 6,
      razorpayKeyId: map['razorpayKeyId'] ?? 'rzp_test_1DP5mmOlF5G5ag',
    );
  }
}
