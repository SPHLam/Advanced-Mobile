class TokenUsageResponse {
  final int availableTokens;
  final int totalTokens;
  final bool unlimited;
  final DateTime date;

  TokenUsageResponse({
    required this.availableTokens,
    required this.totalTokens,
    required this.unlimited,
    required this.date,
  });

  factory TokenUsageResponse.fromJson(Map<String, dynamic> json) {
    return TokenUsageResponse(
      availableTokens: json['availableTokens'],
      totalTokens: json['totalTokens'],
      unlimited: json['unlimited'],
      date: DateTime.parse(json['date']),
    );
  }
}
