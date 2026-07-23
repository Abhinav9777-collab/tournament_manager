class PlayerModel {
  final String id;
  String name; // Mutable field for live profile name changes
  final String email;
  final Map<String, int> tournamentScores;
  final Map<String, Map<String, int>> gameStats;
  final String? activeDeviceSignature;

  PlayerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.tournamentScores,
    Map<String, Map<String, int>>? gameStats,
    this.activeDeviceSignature,
  }) : gameStats = gameStats ?? {};

  // Clone constructor to support hardware & profile mutations safely inside providers
  PlayerModel copyWith({
    String? name,
    String? activeDeviceSignature,
  }) {
    return PlayerModel(
      id: id,
      name: name ?? this.name,
      email: email,
      tournamentScores: tournamentScores,
      gameStats: gameStats,
      activeDeviceSignature: activeDeviceSignature ?? this.activeDeviceSignature,
    );
  }

  // 💾 Convert PlayerModel Object to JSON Map for 100% Disk Storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'tournamentScores': tournamentScores,
      'gameStats': gameStats.map((roomId, statsMap) => MapEntry(roomId, statsMap)),
      'activeDeviceSignature': activeDeviceSignature,
    };
  }

  // 💾 Restore PlayerModel Object from Disk JSON Map
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    // Parse tournamentScores map safely
    Map<String, int> parsedScores = {};
    if (json['tournamentScores'] != null) {
      (json['tournamentScores'] as Map<String, dynamic>).forEach((key, value) {
        parsedScores[key] = (value as num).toInt();
      });
    }

    // Parse nested gameStats map safely
    Map<String, Map<String, int>> parsedGameStats = {};
    if (json['gameStats'] != null) {
      (json['gameStats'] as Map<String, dynamic>).forEach((roomId, statsObj) {
        Map<String, int> innerStats = {};
        if (statsObj is Map) {
          statsObj.forEach((statKey, statVal) {
            innerStats[statKey.toString()] = (statVal as num).toInt();
          });
        }
        parsedGameStats[roomId] = innerStats;
      });
    }

    return PlayerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      tournamentScores: parsedScores,
      gameStats: parsedGameStats,
      activeDeviceSignature: json['activeDeviceSignature'],
    );
  }
}