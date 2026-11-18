import 'package:maximum_maps/core/map/models/map.style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapStyleService {
  static const String _preferenceKey = 'map_style';

  Future<MapStyle> getSavedStyle() async {
    final preferences = await SharedPreferences.getInstance();

    final savedStyle = preferences.getString(_preferenceKey);

    return MapStyle.values.firstWhere(
      (style) => style.name == savedStyle,
      orElse: () => MapStyle.light,
    );
  }

  Future<void> saveStyle(MapStyle style) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _preferenceKey, 
      style.name,
    );
  }
}