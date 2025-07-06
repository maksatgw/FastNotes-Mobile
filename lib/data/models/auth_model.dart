class AuthModel {
  final String token;
  final String refreshToken;
  final String userId;

  AuthModel({
    required this.token,
    required this.refreshToken,
    required this.userId,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'],
      refreshToken: json['refreshToken'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'userId': userId,
    };
  }
}
