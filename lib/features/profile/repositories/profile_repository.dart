import '../models/pofile_details.dart';
import '../models/profile_photo.dart';

class ProfileRepository {
  // Mock data - would be replaced with API calls in a real app.
  Future<ProfileDetails> getProfileDetails(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    //mock data
    return ProfileDetails(
      id: "user123",
      name: "John Doe",
      bio: "I'm a software developer",
      gender: "Male",
      relationshipGoal: "Relationship",
      isProfileCompleted: true,
      verificationStatus: "completed",
      department: "Computer Science",
      program: "UG",
      year: "2020",
      isPremium: false,
      joinedAt: DateTime(2025, 9, 19),
      preferences: {
        "showYear": true,
        "showDepartment": true,
        "darkMode": true,
        "notifications": true,
        "matchAlerts": true,
        "messageAlerts": true,
      },
      // studentIdPhotoUrl: "https://via.placeholder.com/150",
    );
  }

  Future<List<ProfilePhoto>> getUserPhotos(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    //mock data
    return [
      ProfilePhoto(
        id: "photo1",
        url: "https://via.placeholder.com/150",
        isPrimary: true,
        uploadDate: DateTime(2025, 9, 19),
      ),
      ProfilePhoto(
        id: "photo2",
        url: "https://via.placeholder.com/150",
        isPrimary: false,
        uploadDate: DateTime(2025, 9, 19),
      ),
      ProfilePhoto(
        id: "photo3",
        url: "https://via.placeholder.com/150",
        isPrimary: false,
        uploadDate: DateTime(2025, 9, 19),
      ),
      ProfilePhoto(
        id: "photo4",
        url: "https://via.placeholder.com/150",
        isPrimary: true,
        uploadDate: DateTime(2025, 9, 19),
      ),
    ];
  }

  Future<void> updateProfile(ProfileDetails details) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> updatePhotos(List<ProfilePhoto> photos) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> upgardeToPremium() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
