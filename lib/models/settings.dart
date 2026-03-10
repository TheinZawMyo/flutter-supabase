class AppSettings {
  final String userId;
  final String currencyCode;
  final String currencySymbol;

  AppSettings({
    required this.userId,
    required this.currencyCode,
    required this.currencySymbol,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      userId: json['user_id'] as String,
      currencyCode: (json['currency_code'] ?? 'MMK') as String,
      currencySymbol: (json['currency_symbol'] ?? 'Ks') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
    };
  }

  AppSettings copyWith({String? currencyCode, String? currencySymbol}) {
    return AppSettings(
      userId: userId,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}
