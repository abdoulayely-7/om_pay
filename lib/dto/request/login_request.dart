class LoginRequest {
  final String identifier;
  final String password;
  final String? code;

  LoginRequest({
    required this.identifier,
    required this.password,
    this.code,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "identifier": identifier,
      "password": password,
    };

    if (code != null && code!.isNotEmpty) {
      data["code"] = code!;
    }

    return data;
  }
}