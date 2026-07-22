import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player_model.dart';
import '../models/tournament_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Tournament Operations
  Future<void> createTournament(TournamentModel tournament) async {
    await _db.collection('tournaments').doc(tournament.id).set(tournament.toMap());
  }

  Stream<List<TournamentModel>> streamTournaments(String hostId) {
    return _db
        .collection('tournaments')
        .where('hostId', isEqualTo: hostId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => TournamentModel.fromMap(doc.data())).toList());
  }

  // Player Operations
  Future<void> addPlayer(String tournamentId, PlayerModel player) async {
    await _db
        .collection('tournaments')
        .doc(tournamentId)
        .collection('players')
        .doc(player.id)
        .set(player.toMap());
  }

  Future<void> deletePlayer(String tournamentId, String playerId) async {
    await _db
        .collection('tournaments')
        .doc(tournamentId)
        .collection('players')
        .doc(playerId)
        .delete();
  }

  Stream<List<PlayerModel>> streamPlayers(String tournamentId) {
    return _db
        .collection('tournaments')
        .doc(tournamentId)
        .collection('players')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => PlayerModel.fromMap(doc.data())).toList());
  }
}