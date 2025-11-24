class RetraitRequest {
  final String telephone;
  final double montant;

  RetraitRequest({
    required this.telephone,
    required this.montant,
  });

  Map<String, dynamic> toJson() {
    return {
      "telephone": telephone,
      "montant": montant,
    };
  }
}