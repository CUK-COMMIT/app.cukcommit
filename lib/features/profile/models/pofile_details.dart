class ProfileDetails {
  final String id;
  final String? name;
  final String? bio;
  final String? gender;
  final String? relationshipGoal;
  final bool? isProfileCompleted;
  final String? verificationStatus;
  final String? department;
  final String? program; // Added program field
  final String? year;
  final bool isPremium;
  final DateTime joinedAt;
  // final String? studentIdPhotoUrl;
  final Map<String, bool> preferences;

  ProfileDetails({
    required this.id,
    required this.name,
    required this.bio,
    required this.gender,
    required this.relationshipGoal,
    required this.isProfileCompleted,
    required this.verificationStatus,
    required this.department,
    required this.program,
    required this.year,
    required this.preferences,
    this.isPremium = false,
    required this.joinedAt,
    // this.studentIdPhotoUrl,
  });

  factory ProfileDetails.fromMap(Map<String, dynamic> map) {
    return ProfileDetails(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      gender: map['gender'] ?? '',
      relationshipGoal: map['relationship_goal'] ?? '',
      preferences: Map<String, bool>.from(map['preference'] ?? {}),
      isProfileCompleted: map['is_profile_completed'] ?? false,
      verificationStatus: map['verification_status'] ?? '',
      department: map['department'] ?? '',
      program: map['program'] ?? '',
      year: map['year'] ?? '',
      isPremium: map['is_premium'] ?? false,
      joinedAt: map['joined_at'] ?? DateTime.now(),
      // studentIdPhotoUrl: map['student_id_photo_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'gender': gender,
      'relationship_goal': relationshipGoal,
      'preference': preferences,
      'is_profile_completed': isProfileCompleted,
      'verification_status': verificationStatus,
      'department': department,
      'program': program,
      'year': year,
      'is_premium': isPremium,
      'joined_at': joinedAt.toIso8601String(),
      // 'student_id_photo_url': studentIdPhotoUrl,
    };
  }

  ProfileDetails copyWith({
    String? id,
    String? name,
    String? bio,
    String? gender,
    String? relationshipGoal,
    int? onboardingStep,
    bool? isProfileCompleted,
    String? verificationStatus,
    String? department,
    String? program,
    String? year,
    bool? isPremium,
    DateTime? joinedAt,
    // String? studentIdPhotoUrl,
    Map<String, bool>? preferences,
  }) {
    return ProfileDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      relationshipGoal: relationshipGoal ?? this.relationshipGoal,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      department: department ?? this.department,
      program: program ?? this.program,
      year: year ?? this.year,
      isPremium: isPremium ?? this.isPremium,
      joinedAt: joinedAt ?? this.joinedAt,
      // studentIdPhotoUrl: studentIdPhotoUrl ?? this.studentIdPhotoUrl,
      preferences: preferences ?? this.preferences,
    );
  }
}
