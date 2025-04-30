class SubscriptionResponse {
  final String name;
  final int dailyTokens;
  final int monthlyTokens;
  final int annuallyTokens;

  SubscriptionResponse({
    required this.name,
    required this.dailyTokens,
    required this.monthlyTokens,
    required this.annuallyTokens,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      name: json['name'],
      dailyTokens: json['dailyTokens'],
      monthlyTokens: json['monthlyTokens'],
      annuallyTokens: json['annuallyTokens'],
    );
  }
}
