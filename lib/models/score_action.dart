class ScoreAction {
  final bool isLeft;
  final int previousScore;
  final int newScore;
  final bool previousServerWasLeft;

  const ScoreAction({
    required this.isLeft,
    required this.previousScore,
    required this.newScore,
    required this.previousServerWasLeft,
  });
}
