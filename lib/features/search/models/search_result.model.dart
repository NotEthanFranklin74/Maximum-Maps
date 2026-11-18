class SearchResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const SearchResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      name: json["name"] ?? json["display_name"],
      address: json["display_name"],
      latitude: double.parse(json["lat"]),
      longitude: double.parse(json["lon"]),
    );
  }
}