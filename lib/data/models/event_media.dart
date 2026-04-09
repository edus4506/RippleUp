class EventMedia {
  final String id;
  final String idEvent;
  final String imageUrl; //Adicionar depois com o firebase storage

  EventMedia({ 
    required this.id,
    required this.idEvent,
    required this.imageUrl,
  });

  factory EventMedia.fromMap(Map<String, dynamic> map, String documentId) {
    return EventMedia(
      id: documentId,
      idEvent: map['idEvent'] ?? '',
      imageUrl: map['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idEvent': idEvent,
      'url': imageUrl,
    };
  }
}