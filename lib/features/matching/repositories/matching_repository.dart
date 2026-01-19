import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/match_criteria.dart';
import '../models/match_result.dart';

class MatchingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<MatchResult>> getMatches(MatchCriteria criteria) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    final selectQuery = '''
      id,
      roll_no,
      name,
      bio,
      department,
      year,
      gender,
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

    var query = _client
        .from('profiles')
        .select(selectQuery)
        .neq('id', user.id)
        .eq('is_active', true)
        .eq('verification_status', 'completed');

    // Filters
    if (criteria.gender != "All") {
      query = query.eq('gender', criteria.gender);
    }

    if (criteria.year != "All") {
      query = query.eq('year', criteria.year);
    }

    // Online filter -> maps to is_active (since is_online doesn't exist)
    if (criteria.isOnline) {
      query = query.eq('is_active', true);
    }

    final res = await query.order('created_at', ascending: false);
    final list = (res as List).cast<Map<String, dynamic>>();

    var matches = list.map(MatchResult.fromSupabase).toList();

    // interests filter manually
    if (criteria.interests.isNotEmpty) {
      matches = matches.where((m) {
        return m.interests.any((i) => criteria.interests.contains(i));
      }).toList();
    }

    // must have at least 1 photo
    matches = matches.where((m) => m.images.isNotEmpty).toList();

    return matches;
  }

  Future<void> saveMatchCriteria(MatchCriteria criteria) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('match_criteria', jsonEncode(criteria.toMap()));
  }

  Future<MatchCriteria> loadMatchCriteria() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('match_criteria');

    if (jsonStr == null) return const MatchCriteria();

    try {
      return MatchCriteria.fromMap(jsonDecode(jsonStr));
    } catch (_) {
      return const MatchCriteria();
    }
  }

  Future<void> likeProfile(String matchId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    await _client.from("likes").insert({
      "user_id": user.id,
      "liked_user_id": matchId,
    });
  }

  Future<void> dislikeProfile(String matchId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    await _client.from("dislikes").insert({
      "user_id": user.id,
      "disliked_user_id": matchId,
    });
  }

  Future<void> superLikeProfile(String matchId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    await _client.from("super_likes").insert({
      "user_id": user.id,
      "super_liked_user_id": matchId,
    });
  }

  Future<void> reportProfile(String matchId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    await _client.from("reports").insert({
      "user_id": user.id,
      "reported_user_id": matchId,
      "reason": "User reported from discover screen",
    });
  }
}
