class Favorite { 
  final String id;
  final String idUser;
  final String idEvent;

  Favorite({
    required this.id,
    required this.idUser,
    required this.idEvent
  });

  factory Favorite.fromMap(Map<String, dynamic> map, String documentId) {
    return Favorite(
      id: documentId,
      idUser: map['idUser'] ?? '',
      idEvent: map['idEvent'] ?? '',    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'idEvent': idEvent,
    };
  }
}