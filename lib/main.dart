import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: GameCardScreen(),
    );
  }
}

class GameCardScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Card')),
      body: FutureBuilder(
        future: fetchGameData(), /// Вызов функции получения данных
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // } else if (snapshot.hasError) {
          //   return Center(child: Text('Ошибка загрузки данных'));
          // } else if (!snapshot.hasData) {
          //   return Center(child: Text('Нет данных'));
          // }


         // final gameData = snapshot.data as Map<String, dynamic>;


          // final imageUrl = gameData['image'] ??
          //     'assets/image/grass_background.png';

          return GameCard(imageUrl: 'assets/image/grass_background.png');
        },
      ),
    );
  }


  Future<Map<String, dynamic>> fetchGameData() async {
    try {
      final response = await Dio().get('https://odigital.pro/football_fields_api/games/');
      return response.data[0];
    } catch (e) {
      print('Ошибка получения данных: $e');
      throw e;
    }
  }
}

class GameCard extends StatelessWidget {
  final String imageUrl;

  const GameCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            image: DecorationImage(
              image: imageUrl.startsWith('http')
                  ? NetworkImage(imageUrl)
                  : AssetImage(imageUrl) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ваши виджеты
                Text(
                  '22.11.2023 • 16:50',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
