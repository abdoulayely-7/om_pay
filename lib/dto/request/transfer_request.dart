class TransferRequest {
  final String telephoneDestinataire;
  final double montant;

  TransferRequest({
    required this.telephoneDestinataire,
    required this.montant,
  });

  Map<String, dynamic> toJson() {
    return {
      "telephone_destinataire": telephoneDestinataire,
      "montant": montant,
    };
  }
}