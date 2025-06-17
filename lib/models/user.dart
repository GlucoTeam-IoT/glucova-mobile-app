class User {
  final String id;
  final String email;
  final String? name;
  final String token;

  User({
    required this.id,
    required this.email,
    this.name,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    // Asegurar que no haya valores nulos (null safety)
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'], // Permitimos que name sea nulo
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
    };
  }
}
