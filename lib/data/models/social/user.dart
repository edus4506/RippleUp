class Users {
  String uid;
  String name;
  String email;
  String profilePictureUrl;

  Users({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory Users.fromMap(Map<String, dynamic>? map, String documentId) {
    // Se o mapa for nulo, devolvemos um objeto vazio/seguro
    if (map == null) {
      return Users(
        uid: documentId,
        name: 'Unknown User',
        email: '',
        profilePictureUrl: '',
      );
    }

    // Se o mapa existir, usamos os valores ou devolvemos um default
    return Users(
      uid: documentId,
      name: map['name'] ?? 'Unknown User',
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
