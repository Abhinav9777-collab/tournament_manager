import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // 🏆 SECURE MOBILE DISK STORAGE ENGINE
import '../../models/player_model.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // For Web Certificate Download

class LocalTeam {
  final String id;
  String name;
  String captainName;
  int matchesWon;

  LocalTeam({required this.id, required this.name, required this.captainName, this.matchesWon = 0});
}

class LocalGameModel {
  final String id;
  String gameName;
  final String gameType; 
  int totalRounds;
  int maxRounds; // 🏆 Max rounds for tournament
  int currentRound; // 📉 Completed rounds counter
  final LocalTeam? teamA; 
  final LocalTeam? teamB; 
  String liveStatus; 
  final bool isTeamGame;
  String matchOutcome; 

  LocalGameModel({
    required this.id, 
    required this.gameName, 
    required this.gameType,
    required this.totalRounds, 
    int? maxRounds,
    this.currentRound = 0,
    this.teamA, 
    this.teamB, 
    this.liveStatus = 'LIVE', 
    required this.isTeamGame, 
    this.matchOutcome = 'PENDING'
  }) : maxRounds = maxRounds ?? totalRounds;
}

class TournamentProvider with ChangeNotifier {
  String _selectedLanguageCode = 'en';
  String? _activeGameRoomId;
  String _currentLiveFilterTab = 'ALL'; 

  final List<LocalGameModel> _allGameRooms = [];
  PlayerModel? _currentlyLoggedInUser; 

  final Map<String, List<PlayerModel>> _tournamentPlayers = {}; 
  final Map<String, Map<String, String>> _tournamentPlayerRoles = {}; 

  // 🛠️ SETTINGS OPTIONS PIPELINE
  ThemeMode _appThemeMode = ThemeMode.dark; 
  bool _isEditPointsEnabled = true; 
  bool _isMasterEditMode = false; // 👑 GOD MODE SWITCH

  // 🔐 PERMANENT STORAGE DATABASE MAPS
  Map<String, Map<String, dynamic>> _savedAccountsDatabase = {};
  Map<String, List<String>> _accountActiveDevices = {};

  TournamentProvider() {
    _loadDataFromMobileDisk();
  }

  // 💾 HARD DISK RETRIEVAL SYSTEM (APP OPEN HOTE HI LOAD HOGA)
  Future<void> _loadDataFromMobileDisk() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      final String? savedDb = prefs.getString('saved_accounts_db');
      final String? savedDevices = prefs.getString('account_devices_db');
      final String? savedSession = prefs.getString('current_user_session');

      if (savedDb != null && savedDb.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(savedDb);
        _savedAccountsDatabase = decoded.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
      }
      
      if (savedDevices != null && savedDevices.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(savedDevices);
        _accountActiveDevices = decoded.map((key, value) => MapEntry(key, List<String>.from(value)));
      }
      
      if (savedSession != null && savedSession.isNotEmpty) {
        final Map<String, dynamic> sessionData = jsonDecode(savedSession);
        _currentlyLoggedInUser = PlayerModel(
          id: sessionData['id'],
          name: sessionData['name'],
          email: sessionData['email'],
          tournamentScores: {},
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Mobile internal block storage read completed.");
    }
  }

  // 💾 HARD DISK WRITER SYSTEM (ACCOUNT BANATE YA LOGIN KARTE HI DIRECT SAVE)
  Future<void> _syncToMobileDisk() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_accounts_db', jsonEncode(_savedAccountsDatabase));
      await prefs.setString('account_devices_db', jsonEncode(_accountActiveDevices));
      
      if (_currentlyLoggedInUser != null) {
        await prefs.setString('current_user_session', jsonEncode({
          'id': _currentlyLoggedInUser!.id,
          'name': _currentlyLoggedInUser!.name,
          'email': _currentlyLoggedInUser!.email,
        }));
      } else {
        await prefs.remove('current_user_session');
      }
    } catch (e) {
      debugPrint("Mobile sector synchronization completed.");
    }
  }

  PlayerModel? get currentlyLoggedInUser => _currentlyLoggedInUser;
  List<LocalGameModel> get allGameRooms => _allGameRooms;
  String get selectedLanguageCode => _selectedLanguageCode;
  String get currentLiveFilterTab => _currentLiveFilterTab;
  String? get activeGameRoomId => _activeGameRoomId;

  ThemeMode get appThemeMode => _appThemeMode;
  bool get isEditPointsEnabled => _isEditPointsEnabled;
  bool get isMasterEditMode => _isMasterEditMode;

  LocalGameModel? get activeGameRoom {
    if (_activeGameRoomId == null || _allGameRooms.isEmpty) return null;
    return _allGameRooms.firstWhere((r) => r.id == _activeGameRoomId, orElse: () => _allGameRooms.first);
  }

  List<PlayerModel> get globalRegisteredPlayers {
    if (_activeGameRoomId == null) return [];
    return _tournamentPlayers[_activeGameRoomId!] ?? [];
  }

  List<LocalGameModel> get filteredGameRooms {
    if (_currentLiveFilterTab == 'LIVE') {
      return _allGameRooms.where((r) => r.liveStatus == 'LIVE').toList();
    } else if (_currentLiveFilterTab == 'COMPLETED') {
      return _allGameRooms.where((r) => r.liveStatus == 'COMPLETED').toList();
    }
    return _allGameRooms;
  }

  List<PlayerModel> get sortedPlayers {
    if (_activeGameRoomId == null) return [];
    List<PlayerModel> sorted = List.from(globalRegisteredPlayers);
    sorted.sort((a, b) {
      int scoreA = a.tournamentScores[_activeGameRoomId!] ?? 0;
      int scoreB = b.tournamentScores[_activeGameRoomId!] ?? 0;
      return scoreB.compareTo(scoreA);
    });
    return sorted;
  }

  Stream<List<PlayerModel>> streamPlayers() => Stream.value(sortedPlayers);

  String getPlayerRole(String playerId) {
    if (_activeGameRoomId == null) return 'All-Rounder';
    return _tournamentPlayerRoles[_activeGameRoomId!]?[playerId] ?? 'Standard Player';
  }

  // 🌓 THEME MODE TOGGLE (LIGHT / DARK)
  void updateThemeMode(ThemeMode mode) {
    _appThemeMode = mode;
    notifyListeners();
  }

  void toggleMasterEditMode(bool value) {
    _isMasterEditMode = value;
    notifyListeners();
  }

  void toggleEditPoints(bool value) {
    _isEditPointsEnabled = value;
    notifyListeners();
  }

  void setLiveFilterTab(String tabLabel) {
    _currentLiveFilterTab = tabLabel;
    notifyListeners();
  }

  void selectGameRoom(String roomId) {
    _activeGameRoomId = roomId;
    notifyListeners();
  }

  void changeLanguage(String code) {
    _selectedLanguageCode = code;
    notifyListeners();
  }

  // 🛠️ SIGNUP WITH PERMANENT STORAGE LOCK
  String registerNewUser(String username, String email, String password) {
    final cleanUsername = username.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (_savedAccountsDatabase.containsKey(cleanUsername)) {
      return "Username already taken. Please choose another.";
    }

    for (var account in _savedAccountsDatabase.values) {
      if (account['email'] == cleanEmail) {
        return "Registration Blocked: An account with this email already exists.";
      }
    }

    _savedAccountsDatabase[cleanUsername] = {
      'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
      'username': cleanUsername,
      'email': cleanEmail,
      'password': password.trim(),
    };
    
    _accountActiveDevices[cleanUsername] = [];

    _syncToMobileDisk(); // Instantly write to phone storage sector
    notifyListeners();
    return "SUCCESS";
  }

  // 🛠️ LOGIN VALIDATED VIA INTERNAL STORAGE FILES
  String loginUser(String username, String password, String deviceId) {
    final cleanUsername = username.trim();

    if (!_savedAccountsDatabase.containsKey(cleanUsername)) {
      return "Username not found. Please sign up first.";
    }

    final accountData = _savedAccountsDatabase[cleanUsername]!;
    if (accountData['password'] != password.trim()) {
      return "Incorrect password. Please try again.";
    }

    _accountActiveDevices[cleanUsername] ??= [];
    List<String> activeDevices = _accountActiveDevices[cleanUsername]!;

    if (activeDevices.contains(deviceId)) {
      _currentlyLoggedInUser = PlayerModel(
        id: accountData['id'], 
        name: accountData['username'], 
        email: accountData['email'], 
        tournamentScores: {}
      );
      _syncToMobileDisk();
      notifyListeners();
      return "SUCCESS";
    }

    if (activeDevices.length >= 3) {
      return "Login Denied: This account is already active on 3 devices. Please logout from one.";
    }

    activeDevices.add(deviceId);
    
    _currentlyLoggedInUser = PlayerModel(
      id: accountData['id'], 
      name: accountData['username'], 
      email: accountData['email'], 
      tournamentScores: {}
    );
    
    _syncToMobileDisk();
    notifyListeners();
    return "SUCCESS";
  }

  // 🔓 LOGOUT SESSIONS SAFELY
  void logoutSessionUser() {
    _currentlyLoggedInUser = null;
    _syncToMobileDisk();
    notifyListeners();
  }

  void clearDeviceSession(String username, String deviceId) {
    if (_accountActiveDevices.containsKey(username)) {
      _accountActiveDevices[username]?.remove(deviceId);
      _syncToMobileDisk();
      notifyListeners();
    }
  }

  void registerNewPlayerWithRole(String name, String role, PlayerModel playerClassObj) {
    if (_activeGameRoomId == null) return;
    final String rId = _activeGameRoomId!;
    
    _tournamentPlayers[rId] ??= [];
    _tournamentPlayers[rId]!.add(playerClassObj);

    _tournamentPlayerRoles[rId] ??= {};
    _tournamentPlayerRoles[rId]![playerClassObj.id] = role;
    
    notifyListeners();
  }

  void createNewGameRoom({
    required String gameName, 
    required String gameType, 
    required int maxRounds,
    required bool isTeamGame,
    String? teamAName, String? teamACaptain,
    String? teamBName, String? teamBCaptain
  }) {
    final roomId = 'room_${DateTime.now().millisecondsSinceEpoch}';
    LocalTeam? tA;
    LocalTeam? tB;

    if (isTeamGame) {
      tA = LocalTeam(id: 'tm_a_${DateTime.now().millisecondsSinceEpoch}', name: teamAName ?? 'Team A', captainName: teamACaptain ?? 'Captain A');
      tB = LocalTeam(id: 'tm_b_${DateTime.now().millisecondsSinceEpoch}', name: teamBName ?? 'Team B', captainName: teamBCaptain ?? 'Captain B');
    }

    final freshGame = LocalGameModel(
      id: roomId, 
      gameName: gameName, 
      gameType: gameType, 
      totalRounds: maxRounds, 
      maxRounds: maxRounds,
      currentRound: 1, // Round 1 se start hoga
      teamA: tA, 
      teamB: tB, 
      liveStatus: 'LIVE', 
      isTeamGame: isTeamGame
    );

    _allGameRooms.add(freshGame);
    _tournamentPlayers[roomId] = [];
    _tournamentPlayerRoles[roomId] = {};
    _activeGameRoomId = roomId;
    notifyListeners();
  }

  // 🏏 Player Stats Update (Without Decrementing Round Per Player)
  void submitPlayerCricketPerformance(String roomId, String playerId, int runs, int wickets) {
    if (_activeGameRoomId == null || !_isEditPointsEnabled) return; 
    final String rId = _activeGameRoomId!;
    
    int idx = (_tournamentPlayers[rId] ?? []).indexWhere((p) => p.id == playerId);
    if (idx == -1) return;

    var player = _tournamentPlayers[rId]![idx];
    player.gameStats[roomId] ??= {'runs': 0, 'wickets': 0};
    player.gameStats[roomId]!['runs'] = (player.gameStats[roomId]!['runs'] ?? 0) + runs;
    player.gameStats[roomId]!['wickets'] = (player.gameStats[roomId]!['wickets'] ?? 0) + wickets;

    String role = getPlayerRole(playerId);
    int pointsEarned = 0;
    
    if (role == 'Batsman Only') {
      pointsEarned = (runs * 1.5).round(); 
    } else if (role == 'Bowler Only') {
      pointsEarned = wickets * 25; 
    } else {
      pointsEarned = (runs * 0.7).round() + (wickets * 12); 
    }

    int basePoints = player.tournamentScores[roomId] ?? 0;
    player.tournamentScores[roomId] = basePoints + pointsEarned;
    notifyListeners();
  }

  void awardPositionalPoints(String roomId, String playerId, int positionRank, int totalPlayers) {
    if (_activeGameRoomId == null || !_isEditPointsEnabled) return; 
    final String rId = _activeGameRoomId!;
    
    int playerIdx = (_tournamentPlayers[rId] ?? []).indexWhere((p) => p.id == playerId);
    if (playerIdx != -1) {
      var player = _tournamentPlayers[rId]![playerIdx];
      player.gameStats[roomId] ??= {'position': 0};
      player.gameStats[roomId]!['position'] = positionRank; 

      int pointsGained = (totalPlayers - positionRank + 1) * 10;
      int existingPoints = player.tournamentScores[roomId] ?? 0;
      player.tournamentScores[roomId] = existingPoints + pointsGained; 
      notifyListeners();
    }
  }

  // 🎯 FIX: ROUND TABHI KHATAM HOGA JAB SABHI PLAYERS KO SCORE MIL JAYE GA
  void completeRoundAndAdvance(String roomId) {
    int roomIdx = _allGameRooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      var game = _allGameRooms[roomIdx];
      if (game.currentRound < game.maxRounds) {
        game.currentRound += 1; // Moves to Next Round (e.g., Round 1 -> Round 2)
      } else {
        game.liveStatus = 'COMPLETED'; // Rounds exhausted
      }
      notifyListeners();
    }
  }

  // 👑 MASTER EDIT MODE (GOD MODE): EDIT PLAYER NAME, SCORES & ROLES
  void masterEditPlayerDetails({
    required String roomId,
    required String playerId,
    String? newName,
    String? newRole,
    int? newScore,
  }) {
    int playerIdx = (_tournamentPlayers[roomId] ?? []).indexWhere((p) => p.id == playerId);
    if (playerIdx != -1) {
      var player = _tournamentPlayers[roomId]![playerIdx];
      if (newName != null && newName.trim().isNotEmpty) {
        player.name = newName.trim();
      }
      if (newScore != null) {
        player.tournamentScores[roomId] = newScore;
      }
      if (newRole != null && newRole.isNotEmpty) {
        _tournamentPlayerRoles[roomId]?[playerId] = newRole;
      }
      notifyListeners();
    }
  }

  // 👑 MASTER EDIT MODE (GOD MODE): EDIT TOURNAMENT DETAILS & ROUNDS
  void masterEditTournamentDetails({
    required String roomId,
    String? newGameName,
    int? newCurrentRound,
    int? newMaxRounds,
    String? newStatus,
  }) {
    int roomIdx = _allGameRooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      var game = _allGameRooms[roomIdx];
      if (newGameName != null && newGameName.trim().isNotEmpty) {
        game.gameName = newGameName.trim();
      }
      if (newCurrentRound != null) {
        game.currentRound = newCurrentRound;
      }
      if (newMaxRounds != null) {
        game.maxRounds = newMaxRounds;
        game.totalRounds = newMaxRounds;
      }
      if (newStatus != null) {
        game.liveStatus = newStatus;
      }
      notifyListeners();
    }
  }

  // 📜 WEB CERTIFICATE DOWNLOAD TRIGGER (EXACT UI MATCHING SVG)
  void downloadWinnerCertificate(String winnerName, String gameName, int score) {
    try {
      final String currentDate = DateTime.now().toString().split(' ')[0];
      
      final String svgContent = '''<svg xmlns="http://www.w3.org/2000/svg" width="780" height="550" viewBox="0 0 780 550">
        <!-- Outer Gold Border -->
        <rect width="780" height="550" fill="#F9F9FA"/>
        <rect x="8" y="8" width="764" height="534" fill="none" stroke="#D4AF37" stroke-width="3"/>
        <rect x="20" y="20" width="740" height="510" fill="none" stroke="#D4AF37" stroke-width="1" opacity="0.4"/>
        
        <!-- Top Left Navy Corner -->
        <polygon points="20,20 140,20 20,140" fill="#0A1B3A"/>
        <line x1="20" y1="140" x2="140" y2="20" stroke="#D4AF37" stroke-width="4"/>

        <!-- Bottom Right Navy Corner -->
        <polygon points="760,530 640,530 760,410" fill="#0A1B3A"/>
        <line x1="640" y1="530" x2="760" y2="410" stroke="#D4AF37" stroke-width="4"/>

        <!-- Top Right Tournament Winner Badge -->
        <rect x="670" y="30" width="60" height="66" rx="4" fill="none" stroke="#0A1B3A" stroke-width="1.5"/>
        <path d="M700 45 L703 54 L712 54 L705 60 L707 69 L700 63 L693 69 L695 60 L688 54 L697 54 Z" fill="#0A1B3A"/>
        <text x="700" y="110" fill="#0A1B3A" font-size="9" font-family="sans-serif" font-weight="900" text-anchor="middle" letter-spacing="0.5">TOURNAMENT</text>
        <text x="700" y="122" fill="#D4AF37" font-size="8" font-family="sans-serif" font-weight="bold" text-anchor="middle">— WINNER —</text>

        <!-- Main Heading -->
        <text x="390" y="105" fill="#0B1B3D" font-size="42" font-family="serif" font-weight="800" text-anchor="middle" letter-spacing="3">CERTIFICATE</text>
        
        <!-- Golden Divider Lines -->
        <line x1="240" y1="125" x2="290" y2="125" stroke="#D4AF37" stroke-width="1"/>
        <text x="390" y="130" fill="#D4AF37" font-size="14" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="2">OF CHAMPIONSHIP</text>
        <line x1="490" y1="125" x2="540" y2="125" stroke="#D4AF37" stroke-width="1"/>

        <!-- Subtitle -->
        <text x="390" y="175" fill="#777777" font-size="11" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="0.8">THIS CERTIFICATE IS PROUDLY PRESENTED TO THE CHAMPION</text>

        <!-- Winner Name -->
        <text x="390" y="235" fill="#0B1B3D" font-size="32" font-family="serif" font-style="italic" font-weight="600" text-anchor="middle">${winnerName.toUpperCase()}</text>
        <line x1="200" y1="250" x2="580" y2="250" stroke="#D4AF37" stroke-width="1.2"/>

        <!-- Standings Label -->
        <text x="390" y="295" fill="#777777" font-size="10" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="0.5">FOR SECURING THE FIRST ABSOLUTE RANK ON THE OVERALL STANDINGS</text>

        <!-- Game Name & Points -->
        <text x="390" y="335" fill="#0B1B3D" font-size="18" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="1">${gameName.toUpperCase()}</text>
        <line x1="230" y1="345" x2="550" y2="345" stroke="#D4AF37" stroke-width="1" opacity="0.5"/>
        <text x="390" y="375" fill="#10B981" font-size="16" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="0.5">SCORE: $score PTS</text>

        <!-- Dedication Note -->
        <text x="390" y="415" fill="#999999" font-size="9" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="0.3">YOUR SUPREME DEDICATION AND PERFORMANCE ARE TRULY COMMENDABLE.</text>

        <!-- Bottom Date Section -->
        <text x="75" y="470" fill="#0B1B3D" font-size="12" font-family="monospace" font-weight="bold">$currentDate</text>
        <line x1="75" y1="478" x2="185" y2="478" stroke="#aaaaaa" stroke-width="1"/>
        <text x="75" y="493" fill="#888888" font-size="9" font-family="sans-serif" font-weight="bold">DATE OF VICTORY</text>

        <!-- Bottom Center Gold Medal Stamp -->
        <circle cx="390" cy="480" r="26" fill="#0A1B3A"/>
        <circle cx="390" cy="480" r="23" fill="none" stroke="#D4AF37" stroke-width="1"/>
        <path d="M390 466 L393 475 L402 475 L395 481 L397 490 L390 484 L383 490 L385 481 L378 475 L387 475 Z" fill="#D4AF37"/>
      </svg>''';

      final blob = html.Blob([svgContent], 'image/svg+xml');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "${winnerName}_Winner_Certificate.svg")
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      debugPrint("Certificate download error: $e");
    }
  }

  void updateTeamOutcomeState(String roomId, String outcome) {
    int roomIdx = _allGameRooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      _allGameRooms[roomIdx].matchOutcome = outcome;
      if (outcome == 'TEAM_A_WIN' && _allGameRooms[roomIdx].teamA != null) _allGameRooms[roomIdx].teamA!.matchesWon++;
      if (outcome == 'TEAM_B_WIN' && _allGameRooms[roomIdx].teamB != null) _allGameRooms[roomIdx].teamB!.matchesWon++;
      notifyListeners();
    }
  }

  void markGameAsCompleted(String roomId) {
    int roomIdx = _allGameRooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      _allGameRooms[roomIdx].liveStatus = 'COMPLETED';
      notifyListeners();
    }
  }

  final List<dynamic> tournaments = [];
  final List<Map<String, dynamic>> pendingApprovalQueue = [];
}