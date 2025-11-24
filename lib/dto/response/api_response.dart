class ApiResponse<T> {
  final bool success;
  final String message;
  final String timestamp;
  final T? data;
  final dynamic errors;

  ApiResponse({
    required this.success,
    required this.message,
    required this.timestamp,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'],
      message: json['message'],
      timestamp: json['timestamp'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'],
    );
  }
}
