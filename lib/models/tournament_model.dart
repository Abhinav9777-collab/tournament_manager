class TeamModel {
  final String id;
  final String name;
  final String captainName;
  final List<String> playerIds;
  int matchesWon;

  TeamModel({
    required this.id, 
    required this.name, 
    required this.captainName, 
    required this.playerIds, 
    this.matchesWon = 0
  });
}

class GameRoomModel {
  final String id;
  final String gameName;
  final String gameType; 
  final int totalRounds;
  int maxRounds; // 🏆 Maximum rounds limit
  int currentRound; // 📉 Completed rounds tracking
  final TeamModel teamA;
  final TeamModel teamB;
  final String liveStatus; 

  GameRoomModel({
    required this.id, 
    required this.gameName, 
    required this.gameType,
    required this.totalRounds, 
    int? maxRounds,
    this.currentRound = 0,
    required this.teamA, 
    required this.teamB, 
    this.liveStatus = 'LIVE'
  }) : maxRounds = maxRounds ?? totalRounds;
}

class TournamentModel {
  final String id;
  final String name;
  final String hostId; 
  final String gameType;
  final int totalRoundsMax;
  int currentRound; // 📉 Current completed round
  final DateTime createdAt;
  final String roomCode; 
  final String? opponentCaptainId; 
  final List<String> joinedUserIds; 
  final List<String> teamAUserIds;  
  final List<String> teamBUserIds;  
  final bool isPositionsFullyAssigned; 

  TournamentModel({
    required this.id,
    required this.name,
    required this.hostId,
    required this.gameType,
    required this.totalRoundsMax,
    this.currentRound = 0,
    required this.createdAt,
    required this.roomCode,
    this.opponentCaptainId,
    required this.joinedUserIds,
    required this.teamAUserIds,
    required this.teamBUserIds,
    this.isPositionsFullyAssigned = false,
  });
}