import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'city.dart';
import 'city_repository.dart';

class CityCache {
  Future<void> saveCities(List<City> cities) async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = jsonEncode(cities.map((city) => city.toJson()).toList());
    prefs.setString('cached_cities', citiesJson);
  }

  Future<List<City>?> loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getString('cached_cities');
    if (citiesJson != null) {
      final List decoded = jsonDecode(citiesJson);
      return decoded.map((json) => City.fromJson(json)).toList();
    }
    return null;
  }
}
final cityCache = CityCache();

final cityListProvider = FutureProvider.autoDispose<List<City>>((ref) async {
  final cityRepository = CityRepository();
  try {
    final cities = await cityRepository.fetchCities();
    await cityCache.saveCities(cities);
    return cities;
  } catch (e) {
    final cachedCities = await cityCache.loadCities();
    if (cachedCities != null) {
      return cachedCities;
    }
    throw Exception('Error loading cities');
  }
});
