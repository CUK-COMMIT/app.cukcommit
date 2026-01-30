import 'package:cuk_commit/features/matching/models/badge.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cuk_commit/features/profile/providers/profile_provider.dart';

import '../models/exclusive_content.dart';
import '../models/match_criteria.dart';
import '../models/match_result.dart';
import '../repositories/matching_repository.dart';

class MatchingProvider extends ChangeNotifier {
  final MatchingRepository _repo;

  ProfileProvider? _profileProvider;

  // Premium tracking
  DateTime? _premiumStartDate;
  static const String _premiumStartDateKey = "premium_start_date";

  // Exclusive content
  List<ExclusiveContent> _exclusiveContent = [];
  bool _isLoadingContent = false;

  // Matching
  MatchCriteria _criteria = const MatchCriteria();
  List<MatchResult> _matches = [];
  bool _isLoading = false;
  String? _error;

  int _currentMatchIndex = 0;

  MatchingProvider({required MatchingRepository repo}) : _repo = repo {
    _loadSavedCriteria();
    _fetchMatches();
    _loadExclusiveContent();
  }

  // ---------------------------
  // Getters
  // ---------------------------

  bool get isLoading => _isLoading;
  bool get isLoadingContent => _isLoadingContent;

  String? get error => _error;

  List<MatchResult> get matches => _matches;
  MatchCriteria get criteria => _criteria;

  int get currentMatchIndex => _currentMatchIndex;

  MatchResult? get currentMatch =>
      _matches.isNotEmpty && _currentMatchIndex < _matches.length
      ? _matches[_currentMatchIndex]
      : null;

  bool get hasMatches => _matches.isNotEmpty;

  bool get isIncognito => _criteria.isIncognitoMode;

  // Premium
  bool get isPremiumUser => _profileProvider?.isPremium ?? false;

  int get monthsSubscribed {
    if (_premiumStartDate == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(_premiumStartDate!);
    return difference.inDays ~/ 30;
  }

  // Exclusive content
  List<ExclusiveContent> get exclusiveContent => _exclusiveContent;

  // ---------------------------
  // Setup / Init
  // ---------------------------

  void setProfileProvider(ProfileProvider provider) async {
    _profileProvider = provider;

    if (provider.isPremium) {
      await _loadPremiumStartDate();
    }

    notifyListeners();
  }

  Future<void> init() async {
    await _loadSavedCriteria();
    await refreshMatches();
    await _loadExclusiveContent();
  }

  Future<void> _loadPremiumStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_premiumStartDateKey);

    if (dateString == null) {
      _premiumStartDate = DateTime.now();
      await prefs.setString(
        _premiumStartDateKey,
        _premiumStartDate!.toIso8601String(),
      );
    } else {
      _premiumStartDate = DateTime.parse(dateString);
    }
  }

  // ---------------------------
  // Criteria
  // ---------------------------

  Future<void> _loadSavedCriteria() async {
    try {
      _criteria = await _repo.getMatchCriteria();
    } catch (_) {
      _criteria = const MatchCriteria();
    }
    notifyListeners();
  }

  Future<void> updateCriteria(MatchCriteria newCriteria) async {
    _criteria = newCriteria;
    notifyListeners();

    await _repo.saveMatchCriteria(newCriteria);
    await refreshMatches(resetIndex: true);
  }

  /// Toggle incognito mode on/off
  /// Incognito mode is a premium feature that hides your profile from others
  Future<void> toggleIncognitoMode() async {
    if (!isPremiumUser) {
      throw Exception('Incognito mode is a premium feature');
    }

    final newCriteria = _criteria.copyWith(
      isIncognitoMode: !_criteria.isIncognitoMode,
    );

    await updateCriteria(newCriteria);
  }

  /// Set incognito mode to a specific value
  Future<void> setIncognitoMode(bool enabled) async {
    if (enabled && !isPremiumUser) {
      throw Exception('Incognito mode is a premium feature');
    }

    if (_criteria.isIncognitoMode == enabled) {
      return; // Already in the desired state
    }

    final newCriteria = _criteria.copyWith(isIncognitoMode: enabled);

    await updateCriteria(newCriteria);
  }

  List<Badge> getPremiumBadges() {
    return Badge.allBadges;
  }

  // ---------------------------
  // Fetch Matches
  // ---------------------------

  Future<void> _fetchMatches() async {
    await refreshMatches(resetIndex: true);
  }

  Future<void> refreshMatches({bool resetIndex = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // _matches = await _repo.getMatches(_criteria);
      _matches = [
        MatchResult(
          id: 'dummy1',
          userId: 'user_dummy1',
          rollNo: '12345',
          name: 'Aisha',
          images: ['assets/images/user11.jpg', 'assets/images/user12.jpg'],
          bio: 'Love coding and traveling!',
          interests: ['Music', 'Travel'],
          isOnline: true,
          department: 'CSE',
          program: 'UG',
          year: '3',
          gender: 'Female',
        ),
        MatchResult(
          id: 'dummy2',
          userId: 'user_dummy2',
          rollNo: '67890',
          name: 'Rahul',
          images: [
            'assets/images/user21.jpg',
            'assets/images/user22.jpg',
            'assets/images/user23.jpg',
          ],
          bio: 'Future engineer.',
          interests: ['Cricket', 'Movies'],
          isOnline: false,
          department: 'ECE',
          program: 'UG',
          year: '4',
          gender: 'Male',
        ),
        MatchResult(
          id: 'dummy3',
          userId: 'user_dummy3',
          rollNo: '54321',
          name: 'Sneha',
          images: ['assets/images/user31.jpg', 'assets/images/user32.jpeg'],
          bio: 'Music is life.',
          interests: ['Singing', 'Dancing'],
          isOnline: true,
          department: 'BBA',
          program: 'UG',
          year: '2',
          gender: 'Female',
        ),
        MatchResult(
          id: 'dummy4',
          userId: 'user_dummy4',
          rollNo: '11223',
          name: 'Priya',
          images: ['assets/images/user24.jpg', 'assets/images/user25.jpg'],
          bio: 'Psychology major. Understanding minds.',
          interests: ['Reading', 'Coffee'],
          isOnline: false,
          department: 'Psychology',
          program: 'UG',
          year: '1',
          gender: 'Female',
        ),
        MatchResult(
          id: 'dummy5',
          userId: 'user_dummy5',
          rollNo: '33445',
          name: 'Vikram',
          images: ['assets/images/user41.jpg'],
          bio: 'MBA student. Business and Gym.',
          interests: ['Startup', 'Fitness'],
          isOnline: true,
          department: 'MBA',
          program: 'PG',
          year: '2',
          gender: 'Male',
        ),
        MatchResult(
          id: 'dummy6',
          userId: 'user_dummy6',
          rollNo: '55667',
          name: 'Anjali',
          images: ['assets/images/user51.jpg', 'assets/images/user52.jpg'],
          bio: 'Literature lover. Poetry and Art.',
          interests: ['Art', 'Writing'],
          isOnline: true,
          department: 'English',
          program: 'UG',
          year: '3',
          gender: 'Female',
        ),
        MatchResult(
          id: 'dummy7',
          userId: 'user_dummy7',
          rollNo: '77889',
          name: 'Karan',
          images: ['assets/images/user26.jpg'],
          bio: 'Physics enthusiast. Stars and Science.',
          interests: ['Astronomy', 'Gaming'],
          isOnline: false,
          department: 'Physics',
          program: 'UG',
          year: '2',
          gender: 'Male',
        ),
      ];

      if (resetIndex) _currentMatchIndex = 0;

      if (_currentMatchIndex >= _matches.length) {
        _currentMatchIndex = _matches.isEmpty ? 0 : _matches.length - 1;
      }
    } catch (e) {
      _error = e.toString();
      _matches = [];
      _currentMatchIndex = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------
  // Match Navigation
  // ---------------------------

  void nextMatch() {
    if (_matches.isEmpty) return;

    if (_currentMatchIndex < _matches.length - 1) {
      _currentMatchIndex++;
      notifyListeners();
    }
  }

  void previousMatch() {
    if (_matches.isEmpty) return;

    if (_currentMatchIndex > 0) {
      _currentMatchIndex--;
      notifyListeners();
    }
  }

  void resetMatchIndex() {
    _currentMatchIndex = 0;
    notifyListeners();
  }

  // ---------------------------
  // Exclusive Content
  // ---------------------------

  Future<void> _loadExclusiveContent() async {
    _isLoadingContent = true;
    notifyListeners();

    try {
      _exclusiveContent = await _repo.getExclusiveContent();
    } catch (e) {
      _exclusiveContent = [];
      _error = 'Failed to load exclusive content: $e';
    } finally {
      _isLoadingContent = false;
      notifyListeners();
    }
  }

  ExclusiveContent? getContentById(String id) {
    try {
      return _exclusiveContent.firstWhere((content) => content.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------
  // Actions (Correct IDs!)
  // ---------------------------

  /// Like the *current* profile (recommended usage)
  Future<void> likeCurrent() async {
    final m = currentMatch;
    if (m == null) return;
    await _likeMatch(m);
  }

  Future<void> dislikeCurrent() async {
    final m = currentMatch;
    if (m == null) return;
    await _dislikeMatch(m);
  }

  Future<void> superLikeCurrent() async {
    final m = currentMatch;
    if (m == null) return;
    await _superLikeMatch(m);
  }

  Future<void> reportCurrent({
    String reason = "User reported from discover screen",
  }) async {
    final m = currentMatch;
    if (m == null) return;
    await _reportMatch(m, reason: reason);
  }

  /// Backward compatible: old API from UI (matchId = profile row id)
  Future<void> likeProfile(String matchId) async {
    final m = _matches.firstWhere(
      (x) => x.id == matchId,
      orElse: () => throw Exception("Match not found"),
    );
    await _likeMatch(m);
  }

  Future<void> dislikeProfile(String matchId) async {
    final m = _matches.firstWhere(
      (x) => x.id == matchId,
      orElse: () => throw Exception("Match not found"),
    );
    await _dislikeMatch(m);
  }

  Future<void> superLikeProfile(String matchId) async {
    final m = _matches.firstWhere(
      (x) => x.id == matchId,
      orElse: () => throw Exception("Match not found"),
    );
    await _superLikeMatch(m);
  }

  Future<void> reportProfile(
    String matchId, {
    String reason = "User reported from discover screen",
  }) async {
    final m = _matches.firstWhere(
      (x) => x.id == matchId,
      orElse: () => throw Exception("Match not found"),
    );
    await _reportMatch(m, reason: reason);
  }

  Future<void> _likeMatch(MatchResult m) async {
    if (m.id.startsWith('dummy')) {
      _removeMatch(m.id);
      return;
    }

    if ((m.userId ?? '').isEmpty) {
      throw Exception(
        "MatchResult.userId is missing. Fix MatchResult.fromSupabase to include user_id.",
      );
    }

    await _repo.likeProfile(targetUserId: m.userId!, targetProfileId: m.id);

    _removeMatch(m.id);
  }

  Future<void> _dislikeMatch(MatchResult m) async {
    if (m.id.startsWith('dummy')) {
      _removeMatch(m.id);
      return;
    }

    if ((m.userId ?? '').isEmpty) {
      throw Exception(
        "MatchResult.userId is missing. Fix MatchResult.fromSupabase to include user_id.",
      );
    }

    await _repo.dislikeProfile(targetUserId: m.userId!, targetProfileId: m.id);

    _removeMatch(m.id);
  }

  Future<void> _superLikeMatch(MatchResult m) async {
    if (m.id.startsWith('dummy')) {
      _removeMatch(m.id);
      return;
    }

    if ((m.userId ?? '').isEmpty) {
      throw Exception(
        "MatchResult.userId is missing. Fix MatchResult.fromSupabase to include user_id.",
      );
    }

    await _repo.superLikeProfile(
      targetUserId: m.userId!,
      targetProfileId: m.id,
    );

    _removeMatch(m.id);
  }

  Future<void> _reportMatch(MatchResult m, {required String reason}) async {
    if (m.id.startsWith('dummy')) {
      _removeMatch(m.id);
      return;
    }

    if ((m.userId ?? '').isEmpty) {
      throw Exception(
        "MatchResult.userId is missing. Fix MatchResult.fromSupabase to include user_id.",
      );
    }

    await _repo.reportProfile(
      targetUserId: m.userId!,
      targetProfileId: m.id,
      reason: reason,
    );

    _removeMatch(m.id);
  }

  void _removeMatch(String matchId) {
    final removedIndex = _matches.indexWhere((m) => m.id == matchId);
    if (removedIndex == -1) return;

    _matches.removeAt(removedIndex);

    if (_currentMatchIndex >= _matches.length) {
      _currentMatchIndex = _matches.isEmpty ? 0 : _matches.length - 1;
    }

    notifyListeners();
  }

  // ---------------------------
  // Cleanup / Reset
  // ---------------------------

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> resetAll() async {
    _criteria = const MatchCriteria();
    _matches = [];
    _exclusiveContent = [];
    _error = null;
    _currentMatchIndex = 0;

    notifyListeners();

    await _repo.saveMatchCriteria(_criteria);
    await refreshMatches(resetIndex: true);
    await _loadExclusiveContent();
  }
}
