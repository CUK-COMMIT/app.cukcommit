import 'package:cuk_commit/features/matching/models/badge.dart' as custom_badge;

class MatchResult {
  final String id; // profiles.id (row uuid)
  final String? userId; // profiles.user_id (auth uuid)

  final String rollNo;
  final String name;
  final List<String> images;
  final String bio;
  final List<String> interests;
  final bool isOnline;
  final String department;
  final String? program; // nullable to prevent hot reload crash
  final String year;
  final String gender;
  final List<custom_badge.Badge> badges;

  const MatchResult({
    required this.id,
    required this.rollNo,
    required this.name,
    required this.images,
    required this.bio,
    required this.interests,
    required this.isOnline,
    required this.department,
    this.program, // optional
    required this.year,
    required this.gender,
    this.userId,
    this.badges = const [],
  });

  MatchResult copyWith({
    String? id,
    String? userId,
    String? rollNo,
    String? name,
    List<String>? images,
    String? bio,
    List<String>? interests,
    bool? isOnline,
    String? department,
    String? program,
    String? year,
    String? gender,
    List<custom_badge.Badge>? badges,
  }) {
    return MatchResult(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rollNo: rollNo ?? this.rollNo,
      name: name ?? this.name,
      images: images ?? this.images,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      isOnline: isOnline ?? this.isOnline,
      department: department ?? this.department,
      program: program ?? this.program,
      year: year ?? this.year,
      gender: gender ?? this.gender,
      badges: badges ?? this.badges,
    );
  }

  List<custom_badge.Badge> getPremiumBadges() =>
      badges.where((badge) => badge.isPremium).toList();

  factory MatchResult.fromSupabase(Map<String, dynamic> map) {
    // profile_photos join results
    final rawPhotos = map['profile_photos'];
    final images = (rawPhotos is List)
        ? rawPhotos
              .map((e) => e is Map<String, dynamic> ? e['url'] : null)
              .where((u) => u != null)
              .map((u) => u.toString())
              .toList()
        : <String>[];

    // profile_interests join results
    final rawInterests = map['profile_interests'];
    final interests = (rawInterests is List)
        ? rawInterests
              .map((e) => e is Map<String, dynamic> ? e['interest'] : null)
              .where((x) => x != null)
              .map((x) => x.toString())
              .toList()
        : <String>[];

    // Prefer real online status, fallback to active
    final bool isOnline =
        (map['is_online'] as bool?) ?? (map['is_active'] as bool?) ?? false;

    return MatchResult(
      id: (map['id'] ?? "").toString(),
      userId: map['user_id']?.toString(),
      rollNo: (map['roll_no'] ?? "").toString(),
      name: (map['name'] ?? "").toString(),
      images: images,
      bio: (map['bio'] ?? "").toString(),
      interests: interests,
      isOnline: isOnline,
      department: (map['department'] ?? "").toString(),
      program: (map['program'] ?? "UG")
          .toString(), // Default to UG or read from map
      year: (map['year'] ?? "").toString(),
      gender: (map['gender'] ?? "both").toString(),
    );
  }
}
