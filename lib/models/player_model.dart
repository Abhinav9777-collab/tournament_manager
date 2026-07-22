class PlayerModel {
  final String id;
  String name; // 👈 Mutable field for live profile name changes
  final String email;
  final Map<String, int> tournamentScores;
  final Map<String, Map<String, int>> gameStats;
  
  // 🔒 2026 Hardware Signature Lock
  // Stores active machine fingerprint key (Web Session Token or Device UUID)
  final String? activeDeviceSignature;

  PlayerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.tournamentScores,
    Map<String, Map<String, int>>? gameStats,
    this.activeDeviceSignature,
  }) : this.gameStats = gameStats ?? {};

  // Clone constructor to support hardware & profile mutations safely inside providers
  PlayerModel copyWith({
    String? name,
    String? activeDeviceSignature,
  }) {
    return PlayerModel(
      id: this.id,
      name: name ?? this.name,
      email: this.email,
      tournamentScores: this.tournamentScores,
      gameStats: this.gameStats,
      activeDeviceSignature: activeDeviceSignature ?? this.activeDeviceSignature,
    );
  }
}