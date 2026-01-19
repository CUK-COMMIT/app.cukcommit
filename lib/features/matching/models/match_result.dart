class MatchResult {
  final String id;
  final String rollNo;
  final String name;
  final List<String> images;
  final String bio;
  final List<String> interests;
  final bool isOnline; // derived from is_active (since is_online doesn't exist)
  final String department;
  final String year;
  final String gender;

  const MatchResult({
    required this.id,
    required this.rollNo,
    required this.name,
    required this.images,
    required this.bio,
    required this.interests,
    required this.isOnline,
    required this.department,
    required this.year,
    required this.gender,
  });

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

    // since is_online doesn't exist -> use is_active as "online-ish"
    final isActive = (map['is_active'] ?? false) as bool;

    return MatchResult(
      id: (map['id'] ?? "").toString(),
      rollNo: (map['roll_no'] ?? "").toString(),
      name: (map['name'] ?? "").toString(),
      images: images,
      bio: (map['bio'] ?? "").toString(),
      interests: interests,
      isOnline: isActive,
      department: (map['department'] ?? "").toString(),
      year: (map['year'] ?? "").toString(),
      gender: (map['gender'] ?? "both").toString(),
    );
  }
}
