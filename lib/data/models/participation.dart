class Participation {
  final String id;
  final String idUser;
  final String idEvent;

  Participation({
    required this.id,
    required this.idUser,
    required this.idEvent,
  });

  factory Participation.fromMap(Map<String, dynamic> map, String documentId) {
    return Participation(
      id: documentId,
      idUser: map['idUser'] ?? '',
      idEvent: map['idEvent'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'idEvent': idEvent,
    };
  }
}