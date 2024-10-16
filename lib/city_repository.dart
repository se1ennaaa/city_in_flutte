import 'package:dio/dio.dart';
import 'city.dart';

class CityRepository {
  final Dio _dio = Dio();

  Future<List<City>> fetchCities({String? search}) async {
    final response = await _dio.get(
      'https://odigital.pro/football_fields_api/games/',
      queryParameters: search != null ? {'search': search} : null,
    );

    List data = response.data;
    return data.map((city) => City.fromJson(city)).toList();
  }
}
