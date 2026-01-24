import 'dart:convert';

class MatchResult {
  final DateTime date;
  final int leftScore;
  final int rightScore;
  final String leftPlayerName;
  final String rightPlayerName;
  final String winner;

  const MatchResult({
    required this.date,
    required this.leftScore,
    required this.rightScore,
    required this.leftPlayerName,
    required this.rightPlayerName,
    required this.winner,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'leftScore': leftScore,
      'rightScore': rightScore,
      'leftPlayerName': leftPlayerName,
      'rightPlayerName': rightPlayerName,
      'winner': winner,
    };
  }

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      date: DateTime.parse(json['date'] as String),
      leftScore: json['leftScore'] as int,
      rightScore: json['rightScore'] as int,
      leftPlayerName: json['leftPlayerName'] as String,
      rightPlayerName: json['rightPlayerName'] as String,
      winner: json['winner'] as String,
    );
  }

  static String encodeList(List<MatchResult> results) {
    return jsonEncode(results.map((r) => r.toJson()).toList());
  }

  static List<MatchResult> decodeList(String json) {
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((item) => MatchResult.fromJson(item)).toList();
  }
}
