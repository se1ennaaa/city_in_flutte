import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'city.dart';

final searchQueryProvider = StateProvider<String>((ref) => ''); // Провайдер для строки поиска

final cityListProvider = StateNotifierProvider<CityListNotifier, AsyncValue<List<City>>>((ref) {
  return CityListNotifier(ref);
});

class CityListNotifier extends StateNotifier<AsyncValue<List<City>>> {
  final Ref ref;

  CityListNotifier(this.ref) : super(AsyncValue.loading()) {
    fetchCities(); // Вызов метода загрузки при создании
  }

  Future<void> fetchCities() async {
    try {
      // Загр данные из API
      final response = await Dio().get('football_fields_api/games/');
      List<City> cities = (response.data as List).map((city) => City.fromJson(city)).toList();

      // Сохраняем данные в локальное хранилище
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cachedCities', json.encode(cities.map((city) => city.toJson()).toList()));

      // Обновляем состояние
      state = AsyncValue.data(cities);
    } catch (error, stack) {

      print('Ошибка при загрузке городов: $error');


      final prefs = await SharedPreferences.getInstance();
      final cachedCities = prefs.getString('cachedCities');
      if (cachedCities != null) {
        List<dynamic> cachedList = json.decode(cachedCities);
        List<City> cities = cachedList.map((city) => City.fromJson(city)).toList();
        state = AsyncValue.data(cities); // Загружаем данные из кэша
      } else {
        state = AsyncValue.error(error, stack); // Если кэш пуст, возвращаем ошибку с стеком
      }
    }
  }
}
