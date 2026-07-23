import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; 
import 'dart:math' as math; 
import '../../providers/tournament_provider.dart';
import '../../models/player_model.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentScreenState = 'DASHBOARD'; 
  String _activeSidebarTab = 'Dashboard'; 
  String _searchQuery = ""; 
  String _selectedRoleDraftType = 'All-Rounder'; 

  final _addPlayerNameCtrl = TextEditingController();
  final _addPlayerEmailCtrl = TextEditingController();
  
  final _teamANameController = TextEditingController();
  final _teamBNameController = TextEditingController();

  final _runsInputCtrl = TextEditingController();
  final _wicketsInputCtrl = TextEditingController();

  final Map<String, List<String>> _gameFormatsDatabase = {
    'Cricket': ['T10 Cricket', 'T20 Cricket', 'ODI Cricket', 'Test Cricket', 'Box Cricket', 'Tennis Ball Cricket', 'Gully Cricket'],
    'Football': ['Football', 'Futsal', 'Five-a-Side Football', 'Seven-a-Side Football'],
    'Badminton': ['Singles', 'Doubles', 'Mixed Doubles'],
    'Volleyball': ['Volleyball', 'Beach Volleyball'],
    'Basketball': ['Basketball', '3x3 Basketball'],
    'Hockey': ['Field Hockey', 'Indoor Hockey'],
    'Kabaddi': ['Kabaddi', 'Circle Kabaddi', 'Beach Kabaddi'],
    'Tennis': ['Lawn Tennis', 'Doubles Tennis', 'Mixed Tennis'],
    'Table Tennis': ['Singles', 'Doubles'],
    'Chess': ['Classical Chess', 'Rapid Chess', 'Blitz Chess', 'Bullet Chess'],
    'Indoor Games': ['Carrom', 'Ludo', 'UNO', 'Snake & Ladder', 'Business', 'Monopoly', 'Scrabble'],
    'Traditional Games': ['Kho Kho', 'Gilli Danda', 'Lagori', 'Kancha', 'Pittu', 'Tug of War'],
    'Office / College Games': ['Coding Contest', 'Hackathon', 'Quiz Competition', 'Debate', 'Treasure Hunt']
  };

  List<String> _getDynamicSpecialtiesForGame(String gameTypeString) {
    if (gameTypeString.contains('Cricket')) {
      return ['Batsman Only', 'Bowler Only', 'All-Rounder'];
    } else if (gameTypeString.contains('Football') || gameTypeString.contains('Hockey')) {
      return ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'];
    } else if (gameTypeString.contains('Badminton') || gameTypeString.contains('Tennis') || gameTypeString.contains('Table Tennis')) {
      return ['Singles Specialist', 'Doubles Specialist'];
    } else if (gameTypeString.contains('Kabaddi')) {
      return ['Raider', 'Left Corner Defender', 'Right Corner Defender', 'All-Rounder'];
    } else if (gameTypeString.contains('Chess') || gameTypeString.contains('Indoor Games')) {
      return ['Attacking Style', 'Defensive Strategy', 'Tactical Master'];
    } else {
      return ['Solo Player', 'Team Contender', 'Versatile Contender'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TournamentProvider>(context);

    if (provider.currentlyLoggedInUser == null) {
      return LoginScreen(
        onLoginSuccess: () => setState(() => _currentScreenState = 'DASHBOARD'),
        onNavigateToSignup: () => setState(() => _currentScreenState = 'SIGNUP'),
      );
    }
    final currentUser = provider.currentlyLoggedInUser!;

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 768;
    bool isTablet = screenWidth >= 768 && screenWidth < 1150;

    bool isLight = provider.appThemeMode == ThemeMode.light;
    Color bgColor = isLight ? const Color(0xFFF8FAFC) : const Color(0xFF020308);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: isMobile ? AppBar(
        backgroundColor: isLight ? const Color(0xFF1E293B) : const Color(0xFF060813),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('TOURNAMENT MANAGER', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,
      drawer: isMobile ? Drawer(
        child: Container(
          color: const Color(0xFF060813),
          child: _buildSidebarContentTree(provider, currentUser, isLight),
        ),
      ) : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: isTablet ? 220 : 260,
              decoration: const BoxDecoration(
                color: Color(0xFF060813),
                border: Border(right: BorderSide(color: Color(0xFF16192E), width: 1)),
              ),
              child: _buildSidebarContentTree(provider, currentUser, isLight),
            ),

          Expanded(
            child: Column(
              children: [
                _buildTopRibbonHeaderView(currentUser, provider, isLight),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: _buildConditionalContentRouteBody(provider, currentUser.id, isLight),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebarContentTree(TournamentProvider provider, PlayerModel currentUser, bool isLight) {
    return Column(
      children: [
        const SizedBox(height: 35),
        _buildSystemLogoBanner(),
        const SizedBox(height: 30),
        _buildSidebarUserSessionCard(currentUser),
        const SizedBox(height: 20),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildSidebarNavItem(Icons.grid_view_rounded, 'Dashboard'),
              _buildSidebarNavItem(Icons.sports_esports_rounded, 'Games Library'),
              _buildSidebarNavItem(Icons.people_outline_rounded, 'Players List'),
              _buildSidebarNavItem(Icons.tour_rounded, 'My Tournaments'),
              _buildSidebarNavItem(Icons.emoji_events_rounded, 'Scores & Positions'),
              _buildSidebarNavItem(Icons.badge_rounded, 'Certificates'),
              _buildSidebarNavItem(Icons.settings_suggest_rounded, 'Settings'),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), minimumSize: const Size(double.infinity, 44)),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context); 
              _showLaunchNewTournamentDialog(context, provider, isLight);
            },
            child: const Text("+ Create Tournament", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConditionalContentRouteBody(TournamentProvider provider, String loggedInUserId, bool isLight) {
    switch (_activeSidebarTab) {
      case 'Dashboard': return _buildCleanCoreDashboardView(provider, loggedInUserId, isLight);
      case 'Games Library': return _buildGamesLibraryTabView(isLight);
      case 'Players List': return _buildPlayersRegistryTabView(provider, isLight);
      case 'My Tournaments': return _buildTournamentsActiveHubView(provider, isLight);
      case 'Scores & Positions': return _buildLeaderboardsFunctionalView(provider, isLight);
      case 'Certificates': return _buildRewardsCertificatesTabView(provider, isLight);
      case 'Settings': return _buildSettingsTabView(provider, isLight);
      default: return _buildCleanCoreDashboardView(provider, loggedInUserId, isLight);
    }
  }

  Widget _buildCleanCoreDashboardView(TournamentProvider provider, String loggedInUserId, bool isLight) {
    return SingleChildScrollView(
      key: const ValueKey('MainDashboardView'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsCounterRibbon(provider, isLight),
          const SizedBox(height: 24),
          _buildLiveMatchOverviewCard(provider, isLight),
          const SizedBox(height: 24),
          _buildAnalyticsGraphsIntegrationCard(provider, isLight),
          const SizedBox(height: 24),
          _buildPodiumVisualizer3DCard(provider, isLight),
        ],
      ),
    );
  }
 
  Widget _buildGamesLibraryTabView(bool isLight) {
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color borderColor = isLight ? Colors.black12 : Colors.white10;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: _gameFormatsDatabase.keys.map((category) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.toUpperCase(), style: const TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: _gameFormatsDatabase[category]!.map((subFormat) {
                  return Chip(
                    backgroundColor: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF14182E),
                    side: BorderSide(color: borderColor),
                    label: Text(subFormat, style: TextStyle(color: isLight ? const Color(0xFF1E293B) : Colors.white70, fontSize: 11)),
                  );
                }).toList(),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayersRegistryTabView(TournamentProvider provider, bool isLight) {
    if (provider.activeGameRoomId == null) {
      return Center(child: Text("Please create or select a tournament first.", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38)));
    }

    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("Players in ${provider.activeGameRoom?.gameName}", style: TextStyle(color: mainText, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddPlayerActionModal(context, provider, isLight),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 14, color: Colors.white),
                label: const Text("Add Player", style: TextStyle(fontSize: 10, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A085), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              )
            ],
          ),
          const SizedBox(height: 16),
          _buildLiveSearchBoxPanel(isLight),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<PlayerModel>>(
              stream: provider.streamPlayers(),
              builder: (context, snap) {
                final list = snap.data ?? [];
                final filtered = _searchQuery.isEmpty ? list : list.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
                
                if (filtered.isEmpty) {
                  return Center(child: Text("No players added yet. Click 'Add Player' to register.", style: TextStyle(color: isLight ? Colors.black45 : Colors.white38, fontSize: 12)));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final p = filtered[idx];
                    String r = provider.getPlayerRole(p.id);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(backgroundColor: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF14182E), child: Icon(Icons.person, size: 14, color: isLight ? const Color(0xFF0F172A) : Colors.cyanAccent)),
                      title: Text(p.name, style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text("Role: $r", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38, fontSize: 11)),
                      trailing: provider.isMasterEditMode ? IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber, size: 18),
                        onPressed: () => _showMasterEditPlayerModal(context, provider, provider.activeGameRoomId!, p, isLight),
                      ) : null,
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTournamentsActiveHubView(TournamentProvider provider, bool isLight) {
    if (provider.allGameRooms.isEmpty) {
      return Center(child: Text("No tournaments created yet. Click '+ Create Tournament' to start.", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38)));
    }

    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color mountedCardBg = isLight ? const Color(0xFFE2E8F0) : const Color(0xFF14182E);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tournament List", style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: provider.allGameRooms.length,
              itemBuilder: (context, idx) {
                final t = provider.allGameRooms[idx];
                final bool isMounted = provider.activeGameRoomId == t.id;
                return Card(
                  color: isMounted ? mountedCardBg : cardBg,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(side: BorderSide(color: isMounted ? Colors.cyanAccent : (isLight ? Colors.black12 : Colors.transparent))),
                  child: ListTile(
                    leading: const Icon(Icons.hub, color: Colors.purpleAccent),
                    title: Text(t.gameName, style: TextStyle(color: mainText, fontWeight: FontWeight.bold)),
                    subtitle: Text("Game: ${t.gameType} • Round: ${t.currentRound}/${t.maxRounds} • Status: ${t.liveStatus}", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38, fontSize: 11)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (provider.isMasterEditMode)
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.amber, size: 20),
                            onPressed: () => _showMasterEditTournamentModal(context, provider, t, isLight),
                          ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: isMounted ? Colors.green : const Color(0xFF6C5CE7)),
                          onPressed: () => provider.selectGameRoom(t.id), 
                          child: Text(isMounted ? "Selected ✓" : "Select", style: const TextStyle(fontSize: 11, color: Colors.white))
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => _confirmDeleteTournamentDialog(context, provider, t.id, t.gameName, isLight),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLeaderboardsFunctionalView(TournamentProvider provider, bool isLight) {
    if (provider.activeGameRoomId == null) {
      return Center(child: Text("No tournament selected. Choose one from 'My Tournaments' tab.", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38)));
    }
    return Container(
      padding: const EdgeInsets.all(12),
      child: _buildAdaptiveMultiGameGrid(provider, provider.currentlyLoggedInUser!.id, isLight),
    );
  }

  Widget _buildAdaptiveMultiGameGrid(TournamentProvider provider, String loggedInUserId, bool isLight) {
    final room = provider.activeGameRoom;
    final String targetGame = room?.gameType ?? 'Cricket';
    final String currentId = provider.activeGameRoomId!;
    
    int totalConfiguredRounds = room?.maxRounds ?? 5;
    int currentCompletedRound = room?.currentRound ?? 1;
    int roundsLeft = math.max(0, totalConfiguredRounds - currentCompletedRound + 1);

    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;
    Color rowBg = isLight ? const Color(0xFFF1F5F9) : const Color(0xFF0D0F21);

    return StreamBuilder<List<PlayerModel>>(
      stream: provider.streamPlayers(),
      builder: (context, snap) {
        final allPlayers = snap.data ?? [];
        if (allPlayers.isEmpty) return Center(child: Text("No players added to this tournament yet.", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38)));
        List<PlayerModel> filtered = _searchQuery.isEmpty ? allPlayers : allPlayers.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();

        bool isRankLockActive = allPlayers.any((p) => (p.gameStats[currentId]?['position'] ?? 0) == 0);

        return Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isLight ? Colors.black12 : Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Active Game: ${room?.gameName}", style: TextStyle(color: mainText, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text("Current Round: $currentCompletedRound / $totalConfiguredRounds", style: TextStyle(color: isLight ? Colors.black54 : Colors.white54, fontSize: 10)),
                    ],
                  ),
                  
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.amber),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
                        ),
                        icon: const Icon(Icons.restart_alt_rounded, color: Colors.amber, size: 14),
                        label: const Text("Reset Game", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                        onPressed: () => _confirmResetTournamentDialog(context, provider, currentId, room?.gameName ?? "Game", isLight),
                      ),
                      const SizedBox(width: 8),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9F43), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                        icon: const Icon(Icons.done_all, color: Colors.black, size: 14),
                        label: const Text("Finish Round", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          provider.completeRoundAndAdvance(currentId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ Round Completed! Advanced to next round."), backgroundColor: Colors.green),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: roundsLeft > 0 ? Colors.cyanAccent.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: roundsLeft > 0 ? Colors.cyanAccent : Colors.redAccent),
                        ),
                        child: Text(
                          room?.liveStatus == 'COMPLETED' ? "Match Finished 🏁" : "Rounds Left: $roundsLeft",
                          style: TextStyle(color: roundsLeft > 0 ? (isLight ? const Color(0xFF0284C7) : Colors.cyanAccent) : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            if (isRankLockActive && !targetGame.contains('Cricket'))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: const Text("⏳ RANK REQUIREMENT: Set ranks for ALL players to compute final round scores.", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, idx) {
                  final p = filtered[idx];
                  int globalRankPosition = idx + 1;
                  final stats = p.gameStats[currentId] ?? {'runs': 0, 'wickets': 0, 'position': 0};
                  final int totalComputedScore = p.tournamentScores[currentId] ?? 0;
                  
                  String userRole = provider.getPlayerRole(p.id);
                  List<int> dynamicRankItems = List.generate(allPlayers.length, (index) => index + 1);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: rowBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: isLight ? Colors.black12 : Colors.transparent)),
                    child: Row(
                      children: [
                        Text("#$globalRankPosition", style: const TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: TextStyle(color: mainText, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text("Role: $userRole", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        
                        if (targetGame.contains('Cricket')) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (userRole != 'Bowler Only') Text("R: ${stats['runs'] ?? 0}", style: TextStyle(color: isLight ? Colors.black87 : Colors.white70, fontSize: 11)),
                              if (userRole != 'Bowler Only' && userRole != 'Batsman Only') const SizedBox(width: 6),
                              if (userRole != 'Batsman Only') Text("W: ${stats['wickets'] ?? 0}", style: TextStyle(color: isLight ? Colors.black87 : Colors.white70, fontSize: 11)),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_note_rounded, color: (roundsLeft > 0 || provider.isMasterEditMode) ? const Color(0xFF00B4D8) : Colors.grey, size: 20),
                            onPressed: (roundsLeft > 0 || provider.isMasterEditMode) ? () {
                              _showModernPerformanceEntryDialog(context, provider, currentId, p.id, userRole, isLight);
                            } : () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tournament Rounds Completed! Turn on Master Edit Mode in Settings to override."), backgroundColor: Colors.orange));
                            },
                          )
                        ] 
                        else ...[
                          DropdownButton<int>(
                            value: (stats['position'] ?? 0) == 0 ? null : stats['position'],
                            hint: const Text("Assign Rank", style: TextStyle(color: Color(0xFF00B4D8), fontSize: 11)),
                            dropdownColor: cardBg,
                            underline: const SizedBox(),
                            items: dynamicRankItems.map((int val) {
                              return DropdownMenuItem<int>(
                                value: val, 
                                child: Text("Rank $val", style: TextStyle(color: mainText, fontSize: 11, fontWeight: FontWeight.bold))
                              );
                            }).toList(),
                            onChanged: (roundsLeft > 0 || provider.isMasterEditMode) ? (selectedRank) {
                              if (selectedRank != null) {
                                provider.awardPositionalPoints(currentId, p.id, selectedRank, allPlayers.length);
                              }
                            } : null,
                          ),
                        ],
                        
                        if (provider.isMasterEditMode)
                          IconButton(
                            icon: const Icon(Icons.mode_edit_outline_rounded, color: Colors.amber, size: 18),
                            onPressed: () => _showMasterEditPlayerModal(context, provider, currentId, p, isLight),
                          ),

                        const SizedBox(width: 8),
                        Text("$totalComputedScore Pts", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showModernPerformanceEntryDialog(BuildContext context, TournamentProvider provider, String roomId, String playerId, String role, bool isLight) {
    _runsInputCtrl.clear();
    _wicketsInputCtrl.clear();

    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: Text("Edit Performance ($role)", style: TextStyle(color: mainText, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (role != 'Bowler Only')
              TextField(
                controller: _runsInputCtrl,
                style: TextStyle(color: mainText),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Runs Scored", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54)),
              ),
            if (role != 'Batsman Only')
              TextField(
                controller: _wicketsInputCtrl,
                style: TextStyle(color: mainText),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Wickets Taken", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54)),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              int runs = int.tryParse(_runsInputCtrl.text.trim()) ?? 0;
              int wickets = int.tryParse(_wicketsInputCtrl.text.trim()) ?? 0;
              provider.submitPlayerCricketPerformance(roomId, playerId, runs, wickets);
              Navigator.pop(context);
            },
            child: const Text("Save Score"),
          )
        ],
      ),
    );
  }

  Widget _buildRewardsCertificatesTabView(TournamentProvider provider, bool isLight) {
    if (provider.activeGameRoomId == null) {
      return Center(child: Text("Please select a tournament first.", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38)));
    }

    final allPlayers = provider.sortedPlayers;
    if (allPlayers.isEmpty) {
      return Center(child: Text("Please add players to this tournament first to calculate the top rank.", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38)));
    }

    final PlayerModel winnerPlayer = allPlayers.first; 
    final int winnerScore = winnerPlayer.tournamentScores[provider.activeGameRoomId!] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text("🏆 WINNER UNLOCKED: Certificate generated for Current Rank #1: ${winnerPlayer.name.toUpperCase()}", style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            
            Container(
              constraints: const BoxConstraints(maxWidth: 600), 
              child: AspectRatio(
                aspectRatio: 780 / 550, 
                child: FittedBox(
                  fit: BoxFit.contain, 
                  child: Container(
                    width: 780,
                    height: 550,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FA), 
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 3), 
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -30, left: -30,
                            child: Transform.rotate(
                              angle: -math.pi / 4,
                              child: Container(
                                width: 140, height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0A1B3A), 
                                  border: Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 4)),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: -30, right: -30,
                            child: Transform.rotate(
                              angle: -math.pi / 4,
                              child: Container(
                                width: 140, height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0A1B3A),
                                  border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 4)),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 10, right: 10,
                            child: Column(
                              children: [
                                Container(
                                  width: 50, height: 56,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF0A1B3A), width: 1.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.stars_rounded, color: Color(0xFF0A1B3A), size: 32),
                                ),
                                const SizedBox(height: 6),
                                const Text("TOURNAMENT", style: TextStyle(color: Color(0xFF0A1B3A), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                const Text("— WINNER —", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 8, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),

                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                const Text("CERTIFICATE", style: TextStyle(color: Color(0xFF0B1B3D), fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: 3, fontFamily: 'serif')),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(width: 40, height: 1, color: const Color(0xFFD4AF37)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text("OF CHAMPIONSHIP", style: TextStyle(color: const Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                    ),
                                    Container(width: 40, height: 1, color: const Color(0xFFD4AF37)),
                                  ],
                                ),
                                const SizedBox(height: 35),
                                const Text("THIS CERTIFICATE IS PROUDLY PRESENTED TO THE CHAMPION", style: TextStyle(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                                const SizedBox(height: 14),
                                
                                Container(
                                  width: 440,
                                  padding: const EdgeInsets.only(bottom: 4),
                                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 1.2))),
                                  child: Text(
                                    winnerPlayer.name.toUpperCase(), 
                                    style: const TextStyle(color: Color(0xFF0B1B3D), fontSize: 26, fontWeight: FontWeight.w600, fontFamily: 'serif', fontStyle: FontStyle.italic),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                const Text("FOR SECURING THE FIRST ABSOLUTE RANK ON THE OVERALL STANDINGS", style: TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                const SizedBox(height: 14),
                                
                                Text(
                                  provider.activeGameRoom?.gameName.toUpperCase() ?? "COMPETITION", 
                                  style: const TextStyle(color: Color(0xFF0B1B3D), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                                const SizedBox(height: 4),
                                Container(width: 320, height: 1, color: const Color(0xFFD4AF37).withOpacity(0.5)),
                                const SizedBox(height: 24),
                                const Text("YOUR SUPREME DEDICATION AND PERFORMANCE ARE TRULY COMMENDABLE.", style: TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                                const Spacer(),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30, bottom: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(DateTime.now().toString().split(' ')[0], style: const TextStyle(color: Color(0xFF0B1B3D), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                          Container(width: 110, height: 1, color: Colors.black.withOpacity(0.25), margin: const EdgeInsets.symmetric(vertical: 4)),
                                          const Text("DATE OF VICTORY", style: TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 45),
                                      child: Container(
                                        width: 54, height: 54,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0A1B3A),
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 6)],
                                        ),
                                        child: const Icon(Icons.workspace_premium, color: Color(0xFFD4AF37), size: 36),
                                      ),
                                    ),
                                    const SizedBox(width: 100), 
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.downloadWinnerCertificate(
                  winnerPlayer.name,
                  provider.activeGameRoom?.gameName ?? "Tournament",
                  winnerScore,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Downloading Certificate for ${winnerPlayer.name}!"), backgroundColor: Colors.green)
                );
              }, 
              icon: const Icon(Icons.download_for_offline_rounded, color: Colors.white), 
              label: const Text("DOWNLOAD CERTIFICATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTabView(TournamentProvider provider, bool isLight) {
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("⚙️ SETTINGS & APP CONTROLS", style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 24),

        _buildSettingsGroupSection("System Overrides & Admin Tools", [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 18),
            title: Text("Master Edit Mode (God Mode)", style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text("Allows direct editing of player names, scores, and rounds at any time", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38, fontSize: 10)),
            trailing: Switch(
              value: provider.isMasterEditMode,
              activeColor: Colors.cyanAccent,
              onChanged: (val) {
                provider.toggleMasterEditMode(val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val ? "⚡ Master Edit Mode Enabled!" : "Master Edit Mode Disabled."),
                    backgroundColor: val ? Colors.cyan : Colors.grey,
                  )
                );
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.color_lens_rounded, color: Colors.purpleAccent, size: 18),
            title: Text("Dark Theme Mode", style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text("Toggle between Dark and Light mode themes", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38, fontSize: 10)),
            trailing: Switch(
              value: provider.appThemeMode == ThemeMode.dark,
              activeColor: Colors.purpleAccent,
              onChanged: (val) {
                provider.updateThemeMode(val ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
        ], isLight),

        _buildSettingsGroupSection("Profile Settings", [
          InkWell(
            onTap: () => _showChangeNameDialog(provider, isLight),
            child: _buildSettingsRowItem("Change Name", Icons.badge, isLight, trailingText: provider.currentlyLoggedInUser?.name),
          ),
          InkWell(
            onTap: () => _showChangeUsernameDialog(provider, isLight),
            child: _buildSettingsRowItem("Username Profile", Icons.person_search, isLight, trailingText: "@${provider.currentlyLoggedInUser?.name.toLowerCase()}"),
          ),
        ], isLight),

        _buildSettingsGroupSection("Security & Session Controls", [
          InkWell(
            onTap: () => _showResetPasswordDialog(provider, isLight),
            child: _buildSettingsRowItem("Reset Password", Icons.password, isLight),
          ),
          Divider(color: isLight ? Colors.black12 : Colors.white10),
          InkWell(
            onTap: () {
              provider.logoutSessionUser();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logged out successfully!"), backgroundColor: Colors.orange));
            },
            child: _buildSettingsRowItem("Logout Current Session", Icons.logout_rounded, isLight, isDanger: true),
          ),
        ], isLight),
      ],
    );
  }

  void _confirmDeleteTournamentDialog(BuildContext context, TournamentProvider provider, String roomId, String name, bool isLight) {
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text("Delete Tournament?", style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to permanently delete '$name'? This action cannot be undone.", style: TextStyle(color: isLight ? Colors.black87 : Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              provider.deleteTournamentRoom(roomId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted '$name' successfully!"), backgroundColor: Colors.redAccent));
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  void _confirmResetTournamentDialog(BuildContext context, TournamentProvider provider, String roomId, String name, bool isLight) {
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text("Reset Tournament Game?", style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Text("Resetting '$name' will set current round back to 1, clear all history, and reset player points to 0. Continue?", style: TextStyle(color: isLight ? Colors.black87 : Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              provider.resetTournamentState(roomId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reset '$name'! Starting fresh from Round 1."), backgroundColor: Colors.green));
            },
            child: const Text("Reset Game", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showMasterEditPlayerModal(BuildContext context, TournamentProvider provider, String roomId, PlayerModel player, bool isLight) {
    final nameCtrl = TextEditingController(text: player.name);
    final scoreCtrl = TextEditingController(text: (player.tournamentScores[roomId] ?? 0).toString());
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text("👑 Master Edit Player", style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: TextStyle(color: mainText), decoration: InputDecoration(labelText: "Player Name", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))),
            const SizedBox(height: 10),
            TextField(controller: scoreCtrl, keyboardType: TextInputType.number, style: TextStyle(color: mainText), decoration: InputDecoration(labelText: "Total Score Points", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              provider.masterEditPlayerDetails(
                roomId: roomId,
                playerId: player.id,
                newName: nameCtrl.text.trim(),
                newScore: int.tryParse(scoreCtrl.text.trim()) ?? 0,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Player Master Edits Saved!"), backgroundColor: Colors.green));
            },
            child: const Text("Save Changes"),
          )
        ],
      ),
    );
  }

  void _showMasterEditTournamentModal(BuildContext context, TournamentProvider provider, LocalGameModel game, bool isLight) {
    final nameCtrl = TextEditingController(text: game.gameName);
    final currentRoundCtrl = TextEditingController(text: game.currentRound.toString());
    final maxRoundsCtrl = TextEditingController(text: game.maxRounds.toString());
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text("👑 Master Edit Tournament", style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: TextStyle(color: mainText), decoration: InputDecoration(labelText: "Game Name", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))),
            const SizedBox(height: 10),
            TextField(controller: currentRoundCtrl, keyboardType: TextInputType.number, style: TextStyle(color: mainText), decoration: InputDecoration(labelText: "Current Round", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))),
            const SizedBox(height: 10),
            TextField(controller: maxRoundsCtrl, keyboardType: TextInputType.number, style: TextStyle(color: mainText), decoration: InputDecoration(labelText: "Max Rounds", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              provider.masterEditTournamentDetails(
                roomId: game.id,
                newGameName: nameCtrl.text.trim(),
                newCurrentRound: int.tryParse(currentRoundCtrl.text.trim()),
                newMaxRounds: int.tryParse(maxRoundsCtrl.text.trim()),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tournament Master Edits Saved!"), backgroundColor: Colors.green));
            },
            child: const Text("Save Changes"),
          )
        ],
      ),
    );
  }

  void _showChangeNameDialog(TournamentProvider provider, bool isLight) {
    final ctrl = TextEditingController(text: provider.currentlyLoggedInUser?.name);
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: Text("Change Name", style: TextStyle(color: mainText, fontSize: 14, fontWeight: FontWeight.bold)),
        content: TextField(controller: ctrl, style: TextStyle(color: mainText), decoration: InputDecoration(labelText: "Full Name", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() {
                  provider.currentlyLoggedInUser?.name = ctrl.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name updated successfully!"), backgroundColor: Colors.green));
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _showChangeUsernameDialog(TournamentProvider provider, bool isLight) {
    final ctrl = TextEditingController(text: provider.currentlyLoggedInUser?.name.toLowerCase());
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: Text("Update Username", style: TextStyle(color: mainText, fontSize: 14, fontWeight: FontWeight.bold)),
        content: TextField(controller: ctrl, style: TextStyle(color: mainText), decoration: InputDecoration(labelText: "Username", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username updated!"), backgroundColor: Colors.green));
              }
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  void _showResetPasswordDialog(TournamentProvider provider, bool isLight) {
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: Text("Reset Password", style: TextStyle(color: mainText, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Text("Click confirm to send password reset instructions to your email.", style: TextStyle(color: isLight ? Colors.black87 : Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🔐 Reset link sent to your email!"), backgroundColor: Colors.purpleAccent));
            },
            child: const Text("Confirm"),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsGroupSection(String header, List<Widget> children, bool isLight) {
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color borderColor = isLight ? Colors.black12 : Colors.white10;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: const TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold, fontSize: 13)),
          Divider(color: borderColor, height: 20),
          ...children
        ],
      ),
    );
  }

  Widget _buildSettingsRowItem(String title, IconData icon, bool isLight, {String? trailingText, Widget? trailingWidget, bool isDanger = false}) {
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDanger ? Colors.redAccent : (isLight ? Colors.black54 : Colors.white54), size: 16),
      title: Text(title, style: TextStyle(color: isDanger ? Colors.redAccent : mainText, fontSize: 12)),
      trailing: trailingWidget ?? (trailingText != null ? Text(trailingText, style: TextStyle(color: isLight ? Colors.black45 : Colors.white30, fontSize: 12)) : Icon(Icons.arrow_forward_ios_rounded, size: 12, color: isLight ? Colors.black26 : Colors.white24)),
    );
  }

  Widget _metricBlockCard(String title, String val, String sub, IconData i, Color color, bool isLight) {
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color borderColor = isLight ? Colors.black12 : Colors.white10;
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      width: 140, 
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: TextStyle(color: isLight ? Colors.black45 : Colors.white38, fontSize: 9, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Icon(i, color: color.withOpacity(0.8), size: 12),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: TextStyle(color: mainText, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildMetricsCounterRibbon(TournamentProvider p, bool isLight) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.start,
      children: [
        _metricBlockCard('TOTAL PLAYERS', '${p.sortedPlayers.length}', 'Active Players', Icons.group, const Color(0xFF6C5CE7), isLight),
        _metricBlockCard('TOURNAMENTS', '${p.allGameRooms.length}', 'Active Events', Icons.emoji_events, Colors.blueAccent, isLight),
        _metricBlockCard('TOTAL GAMES', '200+', 'Loaded Formats', Icons.sports_esports, Colors.orangeAccent, isLight),
      ],
    );
  }

  Widget _buildLiveMatchOverviewCard(TournamentProvider p, bool isLight) {
    final room = p.activeGameRoom;
    if (room == null) return Center(child: Text("No game session active.", style: TextStyle(color: isLight ? Colors.black54 : Colors.white54)));

    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color borderColor = isLight ? Colors.black12 : Colors.white10;
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), 
                    decoration: BoxDecoration(color: room.liveStatus == 'COMPLETED' ? Colors.green.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), 
                    child: Text(room.liveStatus == 'COMPLETED' ? "FINISHED" : "LIVE", style: TextStyle(color: room.liveStatus == 'COMPLETED' ? Colors.green : Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold))
                  ),
                  const SizedBox(width: 8),
                  Text("${room.gameName} • Round ${room.currentRound} / ${room.maxRounds}", style: TextStyle(color: isLight ? Colors.black87 : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              Text("Result: ${room.matchOutcome}", style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold))
            ],
          ),
          const SizedBox(height: 16),
          
          if (room.isTeamGame) ...[
            Text("Record Round ${room.currentRound} Outcome:", style: TextStyle(color: isLight ? Colors.black54 : Colors.white54, fontSize: 11)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF14182E), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  onPressed: room.liveStatus == 'COMPLETED' ? null : () => p.recordTeamRoundOutcome(room.id, 'TEAM_A_WIN'),
                  child: Text("${room.teamA?.name ?? 'Team A'} Won 🏆", style: TextStyle(fontSize: 11, color: isLight ? const Color(0xFF0F172A) : Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF14182E), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  onPressed: room.liveStatus == 'COMPLETED' ? null : () => p.recordTeamRoundOutcome(room.id, 'TIE'),
                  child: Text("Match Tie 🤝", style: TextStyle(fontSize: 11, color: isLight ? const Color(0xFF0F172A) : Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF14182E), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  onPressed: room.liveStatus == 'COMPLETED' ? null : () => p.recordTeamRoundOutcome(room.id, 'TEAM_B_WIN'),
                  child: Text("${room.teamB?.name ?? 'Team B'} Won 🏆", style: TextStyle(fontSize: 11, color: isLight ? const Color(0xFF0F172A) : Colors.white)),
                ),
              ],
            ),

            if (room.roundHistory.isNotEmpty) ...[
              Divider(color: borderColor, height: 24),
              const Text("📋 Round-by-Round History:", style: TextStyle(color: Color(0xFF00B4D8), fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Column(
                children: room.roundHistory.map((rec) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text("Round ${rec.roundNumber}: ", style: TextStyle(color: isLight ? Colors.black87 : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(rec.winningTeamName, style: TextStyle(color: rec.outcome == 'TIE' ? Colors.blue : Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              )
            ]
          ] else ...[
            Center(child: Text("Solo match results can be updated in the leaderboard tab.", style: TextStyle(color: isLight ? Colors.black45 : Colors.white38, fontSize: 11))),
          ]
        ],
      ),
    );
  }

  Widget _buildAnalyticsGraphsIntegrationCard(TournamentProvider p, bool isLight) {
    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color borderColor = isLight ? Colors.black12 : Colors.white10;
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pie_chart_rounded, color: Colors.purpleAccent, size: 28),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("App Status", style: TextStyle(color: isLight ? Colors.black45 : Colors.white38, fontSize: 10)),
                  Text("Connected Live", style: TextStyle(color: mainText, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics_rounded, color: Colors.orangeAccent, size: 28),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Top Rank #1", style: TextStyle(color: isLight ? Colors.black45 : Colors.white38, fontSize: 10)),
                  Text(p.sortedPlayers.isNotEmpty ? p.sortedPlayers.first.name : "N/A", style: TextStyle(color: mainText, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPodiumVisualizer3DCard(TournamentProvider p, bool isLight) {
    final room = p.activeGameRoom;
    bool isTeam = room?.isTeamGame ?? false;

    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color borderColor = isLight ? Colors.black12 : Colors.white10;
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 240,
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isTeam ? "TEAM ROUND WINS PODIUM" : "WINNERS PODIUM", style: TextStyle(color: mainText, fontSize: 11, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (isTeam && room != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _podiumColumn("${room.teamA?.name}\n(${room.teamA?.roundsWon ?? 0} Wins)", "Team A", 60, Colors.cyanAccent, isLight),
                _podiumColumn("${room.teamB?.name}\n(${room.teamB?.roundsWon ?? 0} Wins)", "Team B", 60, Colors.purpleAccent, isLight),
              ],
            )
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _podiumColumn(p.sortedPlayers.length > 1 ? p.sortedPlayers[1].name : "Empty", "2nd", 50, Colors.grey, isLight),
                _podiumColumn(p.sortedPlayers.isNotEmpty ? p.sortedPlayers[0].name : "Empty", "1st🥇", 80, Colors.amber, isLight),
                _podiumColumn(p.sortedPlayers.length > 2 ? p.sortedPlayers[2].name : "Empty", "3rd", 40, Colors.orangeAccent, isLight),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildLiveSearchBoxPanel(bool isLight) {
    Color bg = isLight ? Colors.white : const Color(0xFF0F1426);
    Color border = isLight ? Colors.black12 : Colors.white10;
    Color textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: TextField(
        style: TextStyle(color: textColor, fontSize: 13),
        decoration: InputDecoration(icon: const Icon(Icons.search, color: Color(0xFF00B4D8), size: 18), hintText: "Search player by name...", hintStyle: TextStyle(color: isLight ? Colors.black38 : Colors.white24, fontSize: 12), border: InputBorder.none),
        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
      ),
    );
  }

  Widget _buildSystemLogoBanner() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, color: Colors.cyanAccent, size: 20),
        SizedBox(width: 8),
        Text('LEAGUE SYSTEM PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildSidebarUserSessionCard(PlayerModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0F1224), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.cyanAccent.withOpacity(0.15))),
      child: Text("USER: ${user.name.toUpperCase()}\n[ONLINE LIVE ✓]", style: const TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold, height: 1.4)),
    );
  }

  Widget _buildSidebarNavItem(IconData icon, String title) {
    final bool isSelected = _activeSidebarTab == title;
    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: Colors.cyanAccent.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(icon, color: isSelected ? Colors.cyanAccent : Colors.white30, size: 16),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 12)),
      onTap: () {
        setState(() => _activeSidebarTab = title);
        if (Navigator.canPop(context)) Navigator.pop(context); 
      },
    );
  }

  Widget _buildTopRibbonHeaderView(PlayerModel user, TournamentProvider provider, bool isLight) {
    Color barBg = isLight ? Colors.white : const Color(0xFF060813);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      color: barBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text("Welcome, ${user.name}! 👋", style: TextStyle(color: mainText, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Row(
            children: [
              if (provider.isMasterEditMode)
                Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Text("⚡ GOD MODE ON", style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: const Text("🟢 Live System", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _podiumColumn(String player, String place, double ht, Color c, bool isLight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 80),
          child: Text(player, style: TextStyle(color: isLight ? const Color(0xFF0F172A) : Colors.white, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ),
        const SizedBox(height: 4),
        Container(
          width: 65, height: ht,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.withOpacity(0.15), border: Border.all(color: c, width: 1), borderRadius: BorderRadius.circular(6)),
          child: Text(place, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 11)),
        )
      ],
    );
  }

  void _showAddPlayerActionModal(BuildContext context, TournamentProvider provider, bool isLight) {
    final String currentSport = provider.activeGameRoom?.gameType ?? 'Cricket';
    List<String> dynamicRoles = _getDynamicSpecialtiesForGame(currentSport);
    _selectedRoleDraftType = dynamicRoles.first; 

    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: cardBg,
          title: Text("Add New Player", style: TextStyle(color: mainText, fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _addPlayerNameCtrl, 
                style: TextStyle(color: mainText), 
                decoration: InputDecoration(labelText: "Player Name", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))
              ),
              const SizedBox(height: 20),
              Text("Select Player Role:", style: TextStyle(color: isLight ? Colors.black54 : Colors.white54, fontSize: 11)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF14182E), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRoleDraftType,
                    dropdownColor: cardBg,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00B4D8)),
                    items: dynamicRoles.map((String choice) {
                      return DropdownMenuItem<String>(value: choice, child: Text(choice, style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.bold)));
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setModalState(() => _selectedRoleDraftType = newValue);
                      }
                    },
                  ),
                ),
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_addPlayerNameCtrl.text.trim().isEmpty) return;
                
                final freshPlayerObj = PlayerModel(
                  id: 'plr_${DateTime.now().millisecondsSinceEpoch}',
                  name: _addPlayerNameCtrl.text.trim(),
                  email: '${_addPlayerNameCtrl.text.trim().toLowerCase()}@app.io',
                  tournamentScores: {provider.activeGameRoomId!: 0}
                );

                provider.registerNewPlayerWithRole(_addPlayerNameCtrl.text.trim(), _selectedRoleDraftType, freshPlayerObj);
                _addPlayerNameCtrl.clear();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✅ Added ${_addPlayerNameCtrl.text.trim()}! Saved to Storage."), backgroundColor: Colors.green)
                );
              },
              child: const Text("Add Player"),
            )
          ],
        ),
      ),
    );
  }

  void _showLaunchNewTournamentDialog(BuildContext context, TournamentProvider p, bool isLight) {
    final titleCtrl = TextEditingController();
    final roundsCtrl = TextEditingController(text: "5"); 
    String localSelectedGame = 'Cricket';
    String localSelectedSubFormat = 'Gully Cricket';
    bool isTeamMatch = true;

    Color cardBg = isLight ? Colors.white : const Color(0xFF090B16);
    Color mainText = isLight ? const Color(0xFF0F172A) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: cardBg,
          title: Text("Create New Tournament", style: TextStyle(color: mainText, fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: titleCtrl, style: TextStyle(color: mainText), decoration: InputDecoration(labelText: "Tournament Name", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))),
                const SizedBox(height: 16),
                TextField(
                  controller: roundsCtrl, 
                  style: TextStyle(color: mainText), 
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Total Rounds", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54)),
                ),
                const SizedBox(height: 16),
                Text("Select Sport", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38, fontSize: 11)),
                DropdownButton<String>(
                  value: localSelectedGame,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  items: _gameFormatsDatabase.keys.map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(color: mainText, fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    setModalState(() {
                      localSelectedGame = val!;
                      localSelectedSubFormat = _gameFormatsDatabase[localSelectedGame]!.first;
                      isTeamMatch = (localSelectedGame == 'Cricket' || localSelectedGame == 'Football' || localSelectedGame == 'Kabaddi' || localSelectedGame == 'Volleyball' || localSelectedGame == 'Basketball');
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text("Select Format", style: TextStyle(color: isLight ? Colors.black54 : Colors.white38, fontSize: 11)),
                DropdownButton<String>(
                  value: localSelectedSubFormat,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  items: _gameFormatsDatabase[localSelectedGame]!.map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(color: mainText, fontSize: 13)));
                  }).toList(),
                  onChanged: (val) => setModalState(() => localSelectedSubFormat = val!),
                ),
                if (isTeamMatch) ...[
                  Divider(color: isLight ? Colors.black12 : Colors.white24, height: 24),
                  TextField(controller: _teamANameController, style: TextStyle(color: mainText), decoration: InputDecoration(labelText: "Team A Name (Optional)", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))),
                  const SizedBox(height: 10),
                  TextField(controller: _teamBNameController, style: TextStyle(color: mainText), decoration: InputDecoration(labelText: "Team B Name (Optional)", labelStyle: TextStyle(color: isLight ? Colors.black54 : Colors.white54))),
                ]
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                int manualRoundsParsed = int.tryParse(roundsCtrl.text.trim()) ?? 5;
                
                p.createNewGameRoom(
                  gameName: titleCtrl.text.trim(), 
                  gameType: "$localSelectedGame ($localSelectedSubFormat)", 
                  maxRounds: manualRoundsParsed,
                  isTeamGame: isTeamMatch,
                  teamAName: _teamANameController.text.trim(),
                  teamBName: _teamBNameController.text.trim(),
                );
                _teamANameController.clear();
                _teamBNameController.clear();
                Navigator.pop(context);
              },
              child: const Text("Create"),
            )
          ],
        ),
      ),
    );
  }
}