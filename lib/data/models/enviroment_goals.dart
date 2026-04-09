class EnvironmentGoals {
  final String id;
  final String title;
  final String imageUrl; //adicionar depois no firebas store

  EnvironmentGoals({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory EnvironmentGoals.fromMap(Map<String, dynamic> map, String documentId) {
    return EnvironmentGoals(
      id: documentId,
      title: map['title'] ?? '',
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() { //probably wont be used, we only want to make gets, not posts to the db
    return {
      'title': title,
      'image_url' : imageUrl
    };
  }
}