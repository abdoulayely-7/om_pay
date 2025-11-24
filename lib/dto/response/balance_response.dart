class BalanceResponse {
  final double solde;

  BalanceResponse({
    required this.solde,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      solde: double.parse(json['solde'].toString()),
    );
  }
}