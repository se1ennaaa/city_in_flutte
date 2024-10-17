import 'package:flutter/material.dart';
import 'game_model.dart'; // Импортируйте вашу модель

class GameItem extends StatelessWidget {
  final GameModel model;

  const GameItem({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(model.backgroundImg), // Картинка фона
        Text('Organizer: ${model.organizer.username}'),
        Text('Price: ${model.price}'),
        Text('Distance: ${model.distance} km'),
        // Добавьте любые другие данные, которые хотите отобразить
      ],
    );
  }
}
