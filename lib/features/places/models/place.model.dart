class Place {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final double latitude;
  final double longitude;
  final String? description;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  double get lat => latitude;
  double get lon => longitude;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }
}