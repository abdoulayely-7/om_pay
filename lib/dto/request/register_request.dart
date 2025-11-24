class RegisterRequest {
  final String name;
  final String email;
  final String telephone;
  final String password;
  final String passwordConfirmation;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.telephone,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "telephone": telephone,
      "password": password,
      "password_confirmation": passwordConfirmation
    };
  }
}
