class TransactionResource {
  final String id;
  final String type;
  final double montant;
  final String reference;
  final String? dateTransaction;
  final ClientInfo? client;
  final DistributeurInfo? distributeur;

  TransactionResource({
    required this.id,
    required this.type,
    required this.montant,
    required this.reference,
    this.dateTransaction,
    this.client,
    this.distributeur,
  });

  factory TransactionResource.fromJson(Map<String, dynamic> json) {
    return TransactionResource(
      id: json["id"],
      type: json["type"],
      montant: double.parse(json["montant"].toString()),
      reference: json["reference"],
      dateTransaction: json["date_transaction"],
      client: json["client"] != null ? ClientInfo.fromJson(json["client"]) : null,
      distributeur: json["distributeur"] != null ? DistributeurInfo.fromJson(json["distributeur"]) : null,
    );
  }
}

class ClientInfo {
  final String id;
  final String nom;
  final String telephone;

  ClientInfo({
    required this.id,
    required this.nom,
    required this.telephone,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      id: json["id"],
      nom: json["nom"],
      telephone: json["telephone"],
    );
  }
}

class DistributeurInfo {
  final String id;
  final String nom;

  DistributeurInfo({
    required this.id,
    required this.nom,
  });

  factory DistributeurInfo.fromJson(Map<String, dynamic> json) {
    return DistributeurInfo(
      id: json["id"],
      nom: json["nom"],
    );
  }
}