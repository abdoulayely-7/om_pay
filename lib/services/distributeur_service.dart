import '../api/api_service.dart';
import '../dto/request/depot_request.dart';
import '../dto/request/retrait_request.dart';
import '../dto/response/api_response.dart';
import '../dto/response/transaction_response.dart';

class DistributeurService {
  final ApiService api;

  DistributeurService(this.api);

  Future<ApiResponse<TransactionResource>> effectuerDepot(String token, DepotRequest request) async {
    final json = await api.postWithToken("/distributeur/depot", request.toJson(), token);
    return ApiResponse.fromJson(json, (data) => TransactionResource.fromJson(data));
  }

  Future<ApiResponse<TransactionResource>> effectuerRetrait(String token, RetraitRequest request) async {
    final json = await api.postWithToken("/distributeur/retrait", request.toJson(), token);
    return ApiResponse.fromJson(json, (data) => TransactionResource.fromJson(data));
  }
}