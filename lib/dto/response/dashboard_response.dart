class DashboardResponse {
  final UserProfile user;
  final double solde;
  final List<TransactionResource> transactions;
  final String? qrCodePath;

  DashboardResponse({
    required this.user,
    required this.solde,
    required this.transactions,
    this.qrCodePath,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      user: UserProfile.fromJson(json['user']),
      solde: double.parse(json['solde'].toString()),
      transactions: (json['transactions'] as List)
          .map((t) => TransactionResource.fromJson(t))
          .toList(),
      qrCodePath: json['qr_code_path'],
    );
  }
}

class UserProfile {
  final String name;
  final String email;
  final String telephone;
  final String role;

  UserProfile({
    required this.name,
    required this.email,
    required this.telephone,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class TransactionResource {
  final String id;
  final String type;
  final double montant;
  final String reference;
  final String dateTransaction;

  TransactionResource({
    required this.id,
    required this.type,
    required this.montant,
    required this.reference,
    required this.dateTransaction,
  });

  factory TransactionResource.fromJson(Map<String, dynamic> json) {
    return TransactionResource(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      montant: double.parse((json['montant'] ?? 0).toString()),
      reference: json['reference'] ?? '',
      dateTransaction: json['date_transaction'] ?? '',
    );
  }
}