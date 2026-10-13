class UserModel {
  final String id;
  final String username;
  final String email;
  final String password;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
