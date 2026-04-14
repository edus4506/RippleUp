class EventEnvGoals {
  final String id;
  final String idEvent;
  final String idEnvGoal;

  EventEnvGoals({
    required this.id,
    required this.idEvent,
    required this.idEnvGoal
  });

  factory EventEnvGoals.fromMap(Map<String, dynamic> map, String documentId) {
    return EventEnvGoals(
      id: documentId,
      idEvent: map['idEvent'] ?? '',
      idEnvGoal: map['idEnvGoal'] ?? '',    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idEvent': idEvent,
      'idEnvGoal': idEnvGoal,
    };
  }
}