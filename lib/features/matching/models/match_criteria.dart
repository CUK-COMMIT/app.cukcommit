class MatchCriteria {
  final String gender; // "All" | "male" | "female" | "both"
  final String year; // "All" | "1st" | "2nd" ...
  final bool onlineOnly; // true | false
  final bool isIncognitoMode;
  final List<String> interests;

  const MatchCriteria({
    this.gender = "All",
    this.year = "All",
    this.onlineOnly = true,
    this.isIncognitoMode = false,
    this.interests = const [],
  });

  MatchCriteria copyWith({
    String? gender,
    String? year,
    bool? onlineOnly,
    bool? isIncognitoMode,
    List<String>? interests,
  }) {
    return MatchCriteria(
      gender: gender ?? this.gender,
      year: year ?? this.year,
      onlineOnly: onlineOnly ?? this.onlineOnly,
      isIncognitoMode: isIncognitoMode ?? this.isIncognitoMode,
      interests: interests ?? this.interests,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "gender": gender,
      "year": year,
      "onlineOnly": onlineOnly,
      "isIncognitoMode": isIncognitoMode,
      "interests": interests,
    };
  }

  factory MatchCriteria.fromMap(Map<String, dynamic> map) {
    return MatchCriteria(
      gender: (map["gender"] ?? "All").toString(),
      year: (map["year"] ?? "All").toString(),
      onlineOnly: (map["onlineOnly"] ?? false) as bool,
      isIncognitoMode: (map["isIncognitoMode"] ?? false) as bool,
      interests: List<String>.from(map["interests"] ?? const []),
    );
  }
}
