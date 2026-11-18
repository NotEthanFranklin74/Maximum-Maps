import 'package:maximum_maps/features/search/models/search_result.model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchService {
  static const String _baseUrl = 'nominatim.openstreetmap.org';

  Future<List<SearchResult>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.https(
      _baseUrl,
      '/search',
      {
        'q': query,
        'format': 'jsonv2',
        'limit': '5',
        'addressdetails': '1',
        'countrycodes': 'gb',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'AtlasMaps/1.0 (location search)',
        'Accept-Language': 'en-GB',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Location search failed: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((result) => SearchResult.fromJson(result as Map<String, dynamic>)).toList();
  }
}