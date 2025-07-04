class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userId;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userId,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_id': userId,
    };
  }

  // Para crear un contacto (sin ID, se genera en el backend)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
