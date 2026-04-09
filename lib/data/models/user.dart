class Users {
  final String name;
  final String email;

  Users({
    required this.name,
    required this.email,
  });

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }
}