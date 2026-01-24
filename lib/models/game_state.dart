import 'package:badminton_score/models/app_constants.dart';

class GameState {
  final int leftScore;
  final int rightScore;
  final int leftGames;
  final int rightGames;
  final bool isLeftServing;
  final int targetScore;
  final String leftPlayerName;
  final String rightPlayerName;

  const GameState({
    required this.leftScore,
    required this.rightScore,
    required this.leftGames,
    required this.rightGames,
    required this.isLeftServing,
    required this.targetScore,
    required this.leftPlayerName,
    required this.rightPlayerName,
  });

  int get totalPoints => leftScore + rightScore;

  GameState copyWith({
    int? leftScore,
    int? rightScore,
    int? leftGames,
    int? rightGames,
    bool? isLeftServing,
    int? targetScore,
    String? leftPlayerName,
    String? rightPlayerName,
  }) {
    return GameState(
      leftScore: leftScore ?? this.leftScore,
      rightScore: rightScore ?? this.rightScore,
      leftGames: leftGames ?? this.leftGames,
      rightGames: rightGames ?? this.rightGames,
      isLeftServing: isLeftServing ?? this.isLeftServing,
      targetScore: targetScore ?? this.targetScore,
      leftPlayerName: leftPlayerName ?? this.leftPlayerName,
      rightPlayerName: rightPlayerName ?? this.rightPlayerName,
    );
  }

  factory GameState.initial() {
    return const GameState(
      leftScore: 0,
      rightScore: 0,
      leftGames: 0,
      rightGames: 0,
      isLeftServing: true,
      targetScore: AppConstants.defaultTargetScore,
      leftPlayerName: 'Left',
      rightPlayerName: 'Right',
    );
  }
}
