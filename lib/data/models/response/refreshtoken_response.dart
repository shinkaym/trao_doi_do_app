class RefreshTokenResponse {
  final String jwt;

  RefreshTokenResponse({required this.jwt});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(jwt: json['jwt'] as String);
  }
}
