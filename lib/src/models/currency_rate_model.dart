class CurrencyRateModel {
  final Map<String, double> rates;

  CurrencyRateModel({required this.rates});

  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    return CurrencyRateModel(
      rates: (json["data"] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": rates,
    };
  }
}
