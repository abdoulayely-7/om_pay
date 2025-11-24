class DepotRequest {
  final String telephone;
  final double montant;

  DepotRequest({
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