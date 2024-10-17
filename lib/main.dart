import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: GameCardScreen(),
    );
  }
}

class GameCardScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Card')),
      body: GameCardBody(),
    );
  }
}

class GameCardBody extends StatefulWidget {
  @override
  _GameCardBodyState createState() => _GameCardBodyState();
}

class _GameCardBodyState extends State<GameCardBody> {
  String filterType = 'all'; // Значение по умолчанию: "все"
  Position? currentPosition; // Текущая геолокация

  // Список изображений для карточек
  final List<String> imageUrls = [
    'assets/images/grass_background.png',
    'assets/images/black_image.png',
    'assets/images/group.png',
    'assets/images/grass_background.png',
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Запрашиваем геолокацию пользователя
  }

  // Получение текущей позиции пользователя
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Проверяем, включена ли служба геолокации
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Служба геолокации отключена.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Геолокация отклонена.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Геолокация отклонена навсегда. Пожалуйста, разрешите доступ к геолокации.');
    }

    currentPosition = await Geolocator.getCurrentPosition();
    setState(() {}); // Обновляем интерфейс после получения позиции
  }

  Future<List<GameData>> fetchGameData() async {
    try {
      final response =
      await Dio().get('https://odigital.pro/football_fields_api/games/');
      return (response.data['results'] as List)
          .map((data) => GameData.fromJson(data))
          .toList();
    } catch (e) {
      print('Ошибка получения данных: $e');
      throw e;
    }
  }

  List<GameData> filterGames(List<GameData> games) {
    if (filterType == 'nearby' && currentPosition != null) {
      // Пример фильтрации: игры с координатами рядом с пользователем
      return games.where((game) {
        // Здесь можно добавить логику определения расстояния
        // от текущей позиции пользователя до позиции игры.
        return true;
      }).toList();
    }
    return games;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  filterType = 'all'; // Устанавливаем фильтр "Все"
                });
              },
              child: Text('Все'),
            ),
            SizedBox(width: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  filterType = 'nearby'; // Устанавливаем фильтр "Рядом"
                });
              },
              child: Text('Рядом'),
            ),
          ],
        ),
        Expanded(
          child: FutureBuilder<List<GameData>>(
            future: fetchGameData(), // Загружаем данные из API
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Нет доступных игр'));
              } else {
                // Фильтрация данных
                final filteredGames = filterGames(snapshot.data!);
                return ListView.builder(
                  itemCount: filteredGames.length,
                  itemBuilder: (context, index) {
                    final game = filteredGames[index];
                    return GameCard(
                      game: game,
                      imageUrl: imageUrls[index % imageUrls.length],
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class GameData {
  final int id;
  final String title;
  final String contribution;
  final int maxPlayer;
  final String startDate;
  final int existingPlayerCount;
  final Organizer organizer;

  GameData({
    required this.id,
    required this.title,
    required this.contribution,
    required this.maxPlayer,
    required this.startDate,
    required this.existingPlayerCount,
    required this.organizer,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      id: json['id'],
      title: json['title'],
      contribution: json['contribution'],
      maxPlayer: json['max_player'],
      startDate: json['start_date'],
      existingPlayerCount: json['existing_player_count'],
      organizer: Organizer.fromJson(json['organizer']),
    );
  }
}

class Organizer {
  final String name;
  final String surname;

  Organizer({
    required this.name,
    required this.surname,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      name: json['name'],
      surname: json['surname'],
    );
  }
}

class GameCard extends StatelessWidget {
  final GameData game;
  final String imageUrl;

  const GameCard({required this.game, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 4,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset(
                imageUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.black54,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    game.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Организатор: ${game.organizer.name} ${game.organizer.surname}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Макс. игроков: ${game.maxPlayer}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Существующие игроки: ${game.existingPlayerCount}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Взнос: ${game.contribution}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Дата начала: ${game.startDate}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
