class Location {
  final String id;
  final String country;
  final String city;
  final String localName;
  final double latitude;
  final double longitude;
  final String helpNotes;

  Location({
    required this.id,
    required this.country,
    required this.city,
    required this.localName,
    required this.latitude,
    required this.longitude,
    required this.helpNotes,
  });

  factory Location.fromMap(Map<String, dynamic> map, String documentId) {
    return Location(
      id: documentId,
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      localName: map['localName'] ?? '',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      helpNotes: map['helpNotes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'city': city,
      'localName': localName,
      'latitude': latitude,
      'longitude': longitude,
      'helpNotes': helpNotes,
    };
  }
}
