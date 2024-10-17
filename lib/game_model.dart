import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_model.freezed.dart';
part 'game_model.g.dart';

@freezed
class GameModel with _$GameModel {
  const factory GameModel({
    required int id,
    required String backgroundImg,
    required DateTime bookingDate,
    required String paymentType,
    required String price,
    required double distance,
    required int existingPlayerCount,
    required int maxPlayer,
    required double latitude,
    required double longitude,
    required Organizer organizer,
  }) = _GameModel;

  factory GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);
}

@freezed
class Organizer with _$Organizer {
  const factory Organizer({
    required String username,
    required String photo,
  }) = _Organizer;

  factory Organizer.fromJson(Map<String, dynamic> json) => _$OrganizerFromJson(json);
}
