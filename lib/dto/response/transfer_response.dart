class TransferResponse {
  final TransactionResource transactionDebit;
  final TransactionResource transactionCredit;

  TransferResponse({
    required this.transactionDebit,
    required this.transactionCredit,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      transactionDebit: TransactionResource.fromJson(json['transaction_debit']),
      transactionCredit: TransactionResource.fromJson(json['transaction_credit']),
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