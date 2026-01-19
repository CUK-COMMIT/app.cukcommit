import 'package:flutter/foundation.dart';

import '../models/match_criteria.dart';
import '../models/match_result.dart';
import '../repositories/matching_repository.dart';

class MatchingProvider extends ChangeNotifier {
  final MatchingRepository _repo;

  MatchingProvider({MatchingRepository? repo})
      : _repo = repo ?? MatchingRepository();

  bool _loading = false;
  String? _error;
  List<MatchResult> _matches = [];

  MatchCriteria _criteria = const MatchCriteria();

  bool get isLoading => _loading;
  String? get error => _error;
  List<MatchResult> get matches => _matches;
  MatchCriteria get criteria => _criteria;

  Future<void> init() async {
    await loadSavedCriteria();
    await refreshMatches();
  }

  Future<void> loadSavedCriteria() async {
    try {
      _criteria = await _repo.loadMatchCriteria();
    } catch (_) {
      _criteria = const MatchCriteria();
    }
    notifyListeners();
  }

  Future<void> updateCriteria(MatchCriteria newCriteria) async {
    _criteria = newCriteria;
    notifyListeners();

    await _repo.saveMatchCriteria(newCriteria);
    await refreshMatches();
  }

  Future<void> refreshMatches() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _matches = await _repo.getMatches(_criteria);
    } catch (e) {
      _error = e.toString();
      _matches = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> likeProfile(String matchId) async {
    await _repo.likeProfile(matchId);
    _matches.removeWhere((m) => m.id == matchId);
    notifyListeners();
  }

  Future<void> dislikeProfile(String matchId) async {
    await _repo.dislikeProfile(matchId);
    _matches.removeWhere((m) => m.id == matchId);
    notifyListeners();
  }

  Future<void> superLikeProfile(String matchId) async {
    await _repo.superLikeProfile(matchId);
    _matches.removeWhere((m) => m.id == matchId);
    notifyListeners();
  }

  Future<void> reportProfile(String matchId) async {
    await _repo.reportProfile(matchId);
    _matches.removeWhere((m) => m.id == matchId);
    notifyListeners();
  }
}
