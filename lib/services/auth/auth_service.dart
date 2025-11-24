import '../../api/api_service.dart';
import '../../dto/request/login_request.dart';
import '../../dto/request/register_request.dart';
import '../../dto/response/api_response.dart';
import '../../dto/response/login_response.dart';
import '../../dto/response/user_response.dart';

class AuthService {
  final ApiService api;

  AuthService(this.api);

  Future<ApiResponse<UserResource>> register(RegisterRequest request) async {
    final json = await api.post("/auth/register", request.toJson());

    return ApiResponse.fromJson(json, (data) => UserResource.fromJson(data));
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final json = await api.post("/auth/login", request.toJson());

    return LoginResponse.fromJson(json);
  }
}
