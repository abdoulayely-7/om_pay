import '../api/api_service.dart';
import '../dto/request/payment_request.dart';
import '../dto/request/transfer_request.dart';
import '../dto/response/api_response.dart';
import '../dto/response/balance_response.dart';
import '../dto/response/dashboard_response.dart';
import '../dto/response/payment_response.dart';
import '../dto/response/transaction_response.dart' as tr;
import '../dto/response/transfer_response.dart';

class ClientService {
  final ApiService api;

  ClientService(this.api);

  Future<ApiResponse<BalanceResponse>> getBalance(String token) async {
    final json = await api.get("/client/solde", token);

    return ApiResponse.fromJson(json, (data) => BalanceResponse.fromJson(data));
  }

  Future<ApiResponse<DashboardResponse>> getDashboard(String token) async {
    final json = await api.get("/client/dashboard", token);

    return ApiResponse.fromJson(
      json,
      (data) => DashboardResponse.fromJson(data),
    );
  }

  Future<ApiResponse<TransferResponse>> effectuerTransfert(
    String token,
    TransferRequest request,
  ) async {
    final json = await api.postWithToken(
      "/client/transfert",
      request.toJson(),
      token,
    );

    final response = ApiResponse.fromJson(
      json,
      (data) => TransferResponse.fromJson(data),
    );

    //  LANCER UNE EXCEPTION SI ÉCHEC :
    if (!response.success) {
      throw Exception(response.message);
    }

    return response;
  }

  Future<ApiResponse<PaymentResponse>> effectuerPaiement(
    String token,
    PaymentRequest request,
  ) async {
    final json = await api.postWithToken(
      "/client/paiement",
      request.toJson(),
      token,
    );

    return ApiResponse.fromJson(json, (data) => PaymentResponse.fromJson(data));
  }

  Future<List<tr.TransactionResource>> getTransactions(String token) async {
    final json = await api.get("/client/transactions", token);

    // json is the full response object: {success, message, timestamp, data}
    // We need to extract the 'data' field which contains the array
    if (json is Map<String, dynamic> && json.containsKey('data')) {
      final data = json['data'];
      if (data is List) {
        return data
            .map(
              (item) =>
                  tr.TransactionResource.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    }
    throw Exception('Format de réponse inattendu pour les transactions');
  }
}
