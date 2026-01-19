class MatchCriteria {
  final String gender; // "All" | "male" | "female" | "both"
  final String year; // "All" | "1st" | "2nd" ...
  final bool isOnline; // uses is_active since is_online doesn't exist
  final bool isIncognitoMode;
  final List<String> interests;

  const MatchCriteria({
    this.gender = "All",
    this.year = "All",
    this.isOnline = false,
    this.isIncognitoMode = false,
    this.interests = const [],
  });

  MatchCriteria copyWith({
    String? gender,
    String? year,
    bool? isOnline,
    bool? isIncognitoMode,
    List<String>? interests,
  }) {
    return MatchCriteria(
      gender: gender ?? this.gender,
      year: year ?? this.year,
      isOnline: isOnline ?? this.isOnline,
      isIncognitoMode: isIncognitoMode ?? this.isIncognitoMode,
      interests: interests ?? this.interests,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "gender": gender,
      "year": year,
      "isOnline": isOnline,
      "isIncognitoMode": isIncognitoMode,
      "interests": interests,
    };
  }

  factory MatchCriteria.fromMap(Map<String, dynamic> map) {
    return MatchCriteria(
      gender: (map["gender"] ?? "All").toString(),
      year: (map["year"] ?? "All").toString(),
      isOnline: (map["isOnline"] ?? false) as bool,
      isIncognitoMode: (map["isIncognitoMode"] ?? false) as bool,
      interests: List<String>.from(map["interests"] ?? const []),
    );
  }
}
