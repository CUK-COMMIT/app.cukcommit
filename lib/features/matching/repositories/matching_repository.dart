import 'dart:convert';

import 'package:cuk_commit/features/matching/models/badge.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exclusive_content.dart';
import '../models/match_criteria.dart';
import '../models/match_result.dart';

class MatchingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ---- PREMIUM FLAG ----
  bool _isPremium = false;

  bool isPremiumUser() => _isPremium;

  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
  }

  // ============================================================
  // MATCHES
  // ============================================================

  static const String _profileSelectQuery = '''
    id,
    user_id,
    roll_no,
    name,
    bio,
    department,
    year,
    gender,
    is_online,
    is_active,
    verification_status,
    created_at,
    profile_photos:profile_photos(
      url,
      is_primary,
      slot_index
    ),
    profile_interests:profile_interests(
      interest
    )
  ''';

  Future<List<MatchResult>> getMatches(MatchCriteria criteria) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    var query = _client
        .from('profiles')
        .select(_profileSelectQuery)
        .neq('user_id', user.id)
        .eq('is_active', true)
        .eq('verification_status', 'completed');

    // Gender filter
    if (criteria.gender != "All") {
      query = query.eq('gender', criteria.gender);
    }

    // Year filter
    if (criteria.year != "All") {
      query = query.eq('year', criteria.year);
    }

    // Online filter
    if (criteria.onlineOnly == true) {
      query = query.eq('is_online', true);
    }

    // Run
    final res = await query.order('created_at', ascending: false);
    final list = (res as List).cast<Map<String, dynamic>>();

    // Convert
    var matches = list.map(MatchResult.fromSupabase).toList();

    // Must have photos
    matches = matches.where((m) => m.images.isNotEmpty).toList();

    // Interest filter
    if (criteria.interests.isNotEmpty) {
      matches = matches.where((m) {
        return m.interests.any((i) => criteria.interests.contains(i));
      }).toList();
    }

    // Sort by overlap, then online
    matches.sort((a, b) {
      final commonA = _countCommon(a.interests, criteria.interests);
      final commonB = _countCommon(b.interests, criteria.interests);

      if (commonB != commonA) return commonB.compareTo(commonA);
      if (b.isOnline != a.isOnline) return b.isOnline ? 1 : -1;
      return a.name.compareTo(b.name);
    });

    // Update last seen unless true premium + incognito enabled
    final incognito = criteria.isIncognitoMode;
    if (!incognito || !isPremiumUser()) {
      await _updateLastActive();
    }

    return matches;
  }

  int _countCommon(List<String> listA, List<String> listB) {
    if (listB.isEmpty) return 0;
    final setB = listB.toSet();
    return listA.where(setB.contains).length;
  }

  Future<void> _updateLastActive() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client
        .from('profiles')
        .update({
          'last_seen_at': DateTime.now().toIso8601String(),
          'is_online': true,
        })
        .eq('user_id', user.id);
  }

  Future<MatchResult> getMatchById(String matchProfileId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    final res = await _client
        .from('profiles')
        .select(_profileSelectQuery)
        .eq('id', matchProfileId)
        .maybeSingle();

    if (res == null) throw Exception("Match not found");

    return MatchResult.fromSupabase(res);
  }

  List<Badge> getPremiumBadges() {
    return Badge.allBadges;
  }

  // ============================================================
  // MATCH CRITERIA CACHE
  // ============================================================

  Future<void> saveMatchCriteria(MatchCriteria criteria) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('match_criteria', jsonEncode(criteria.toMap()));
  }

  Future<MatchCriteria> getMatchCriteria() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('match_criteria');
    if (jsonStr == null) return const MatchCriteria();

    try {
      return MatchCriteria.fromMap(jsonDecode(jsonStr));
    } catch (_) {
      return const MatchCriteria();
    }
  }

  // ============================================================
  // ACTIONS
  //
  // IMPORTANT:
  // We must store the TARGET USER_ID (auth uuid),
  // not profiles.id (row uuid)
  // ============================================================

  Future<void> likeProfile({
    required String targetUserId,
    String? targetProfileId, // optional for analytics
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    await _client.from("likes").insert({
      "user_id": user.id,
      "liked_user_id": targetUserId,
      if (targetProfileId != null) "liked_profile_id": targetProfileId,
    });
  }

  Future<void> dislikeProfile({
    required String targetUserId,
    String? targetProfileId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    await _client.from("dislikes").insert({
      "user_id": user.id,
      "disliked_user_id": targetUserId,
      if (targetProfileId != null) "disliked_profile_id": targetProfileId,
    });
  }

  Future<void> superLikeProfile({
    required String targetUserId,
    String? targetProfileId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    await _client.from("super_likes").insert({
      "user_id": user.id,
      "super_liked_user_id": targetUserId,
      if (targetProfileId != null) "super_liked_profile_id": targetProfileId,
    });
  }

  Future<void> reportProfile({
    required String targetUserId,
    required String reason,
    String? targetProfileId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    await _client.from("reports").insert({
      "user_id": user.id,
      "reported_user_id": targetUserId,
      "reason": reason,
      if (targetProfileId != null) "reported_profile_id": targetProfileId,
    });
  }

  // ============================================================
  // EXCLUSIVE CONTENT
  //
  // Tries Supabase first, falls back to mock list
  // ============================================================

  final List<ExclusiveContent> _mockExclusiveContent = [
    ExclusiveContent(
      id: "1",
      title: "Exclusive Content 1",
      description: "This is exclusive content 1",
      imageUrl: "https://via.placeholder.com/150",
      content: "This is the content of exclusive content 1",
      publishDate: DateTime.now(),
      tags: ["tag1", "tag2"],
      requiredMonths: 3,
    ),
  ];

  Future<List<ExclusiveContent>> getExclusiveContent() async {
    try {
      final res = await _client
          .from('exclusive_content')
          .select(
            'id,title,description,image_url,content,publish_date,tags,required_months',
          )
          .order('publish_date', ascending: false);

      final list = (res as List).cast<Map<String, dynamic>>();

      return list
          .map(
            (e) => ExclusiveContent(
              id: e['id'].toString(),
              title: (e['title'] ?? '') as String,
              description: (e['description'] ?? '') as String,
              imageUrl: (e['image_url'] ?? '') as String,
              content: (e['content'] ?? '') as String,
              publishDate:
                  DateTime.tryParse((e['publish_date'] ?? '').toString()) ??
                  DateTime.now(),
              tags: ((e['tags'] ?? []) as List)
                  .map((x) => x.toString())
                  .toList(),
              requiredMonths: (e['required_months'] ?? 0) as int,
            ),
          )
          .toList();
    } catch (_) {
      // fallback
      await Future.delayed(const Duration(milliseconds: 200));
      return _mockExclusiveContent;
    }
  }
}
