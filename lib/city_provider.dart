import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'city.dart';

final cityListProvider = FutureProvider<List<City>>((ref) async {
  final Dio dio = Dio();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Попробуем сначала загрузить города из локального хранилища
  final cachedCities = prefs.getStringList('cachedCities');
  if (cachedCities != null) {
    return cachedCities.map((cityJson) => City.fromJson(cityJson as Map<String, dynamic>)).toList();
  }

  // Если кеша нет, то загружаем города с сервера
  final response = await dio.get('https://odigital.pro/locations/cities/');
  final List<dynamic> data = response.data;

  // Преобразуем данные в список объектов City
  final List<City> cities = data.map((json) => City.fromJson(json)).toList();

  // Сохраняем данные в локальное хранилище
  prefs.setStringList('cachedCities', cities.map((city) => city.toJson()).cast<String>().toList());

  return cities;
});
