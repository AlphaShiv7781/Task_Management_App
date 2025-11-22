class UserModel {
  final String accessToken;
  final String refreshToken;

  UserModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
    );
  }
}
