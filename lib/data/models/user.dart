class Users {
  String name;
  String email;
  String profilePictureUrl;

  Users({
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
