class PaymentRequest {
  final String codeMarchand;
  final double montant;

  PaymentRequest({
    required this.codeMarchand,
    required this.montant,
  });

  Map<String, dynamic> toJson() {
    return {
      "code_marchand": codeMarchand,
      "montant": montant,
    };
  }
}