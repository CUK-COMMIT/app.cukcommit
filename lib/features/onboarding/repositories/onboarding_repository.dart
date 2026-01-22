import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ============================
  // Profile core info
  // ============================

  /// Step values:
  /// 0 = profile setup
  /// 1 = photo upload
  /// 2 = interests
  /// 3 = student verification
  /// 4 = completed (profile ready)
  Future<void> saveUserProfileData({
    required String name,
    required String gender,
    required String relationshipGoal,
    required String matchPreference,
    String? bio,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in (Supabase session missing)");
    }

    await _client.from("profiles").upsert({
      "id": user.id,
      "name": name.trim(),
      "email": user.email ?? "",
      "bio": bio?.trim(),
      "gender": gender.trim(),
      "relationship_goal": relationshipGoal.trim(),
      "match_preference": matchPreference.trim(),

      // onboarding progress
      "onboarding_step": 1, // next = photo upload
      "is_profile_completed": false,

      // student verification
      "verification_status": "unverified",

      "updated_at": DateTime.now().toIso8601String(),
    });
  }

  // ============================
  // Onboarding step control
  // ============================

  Future<void> setOnboardingStep(int step) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _client.from("profiles").update({
      "onboarding_step": step,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq("id", user.id);
  }

  /// Used by AuthGate
  Future<Map<String, dynamic>?> getOnboardingState() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return await _client
        .from("profiles")
        .select("is_profile_completed, onboarding_step, verification_status")
        .eq("id", user.id)
        .maybeSingle();
  }

  Future<bool> isProfileCompleted() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final res = await _client
        .from("profiles")
        .select("is_profile_completed")
        .eq("id", user.id)
        .maybeSingle();

    if (res == null) return false;
    return (res["is_profile_completed"] ?? false) == true;
  }

  // ============================
  // Photos (DB table: profile_photos)
  // ============================

  Future<void> upsertPhotoSlot({
    required int slotIndex,
    required String url,
    bool isPrimary = false,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _client.from("profile_photos").upsert({
      "user_id": user.id,
      "slot_index": slotIndex,
      "url": url,
      "is_primary": isPrimary,
    });
  }

  Future<void> deletePhotoSlot({
    required int slotIndex,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _client
        .from("profile_photos")
        .delete()
        .eq("user_id", user.id)
        .eq("slot_index", slotIndex);
  }

  Future<List<Map<String, dynamic>>> getMyPhotos() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final res = await _client
        .from("profile_photos")
        .select("slot_index, url, is_primary")
        .eq("user_id", user.id)
        .order("slot_index", ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  /// Called after user has >=2 photos and clicks next
  Future<void> completePhotoStep() async {
    await setOnboardingStep(2); // next = interests
  }

  // ============================
  // Interests (DB table: profile_interests)
  // ============================

  Future<void> saveInterests(List<String> interests) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final cleaned = interests
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    // delete old
    await _client.from("profile_interests").delete().eq("user_id", user.id);

    // insert new
    if (cleaned.isNotEmpty) {
      await _client.from("profile_interests").insert(
            cleaned
                .map((interest) => {
                      "user_id": user.id,
                      "interest": interest,
                    })
                .toList(),
          );
    }
  }

  Future<void> markInterestsCompleted() async {
    await setOnboardingStep(3); // next = student verification
  }

  // ============================
  // Student Verification
  // ============================

  /// Save student verification info into profiles table.
  /// (You can also create a separate table later if needed.)
  Future<void> saveStudentVerification({
    required String rollNo,
    required String department,
    required String year,
    required String program, // UG / PG / PhD
    required String idPhotoUrl, // upload to Supabase Storage first
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _client.from("profiles").update({
      "roll_no": rollNo.trim(),
      "department": department.trim(),
      "year": year.trim(),
      "program": program.trim(),
      "student_id_photo_url": idPhotoUrl.trim(),
      "verification_status": "completed",
      "is_profile_completed": true,

      "updated_at": DateTime.now().toIso8601String(),
    }).eq("id", user.id);
  }

  /// After submitting student verification
  Future<void> markStudentVerificationSubmitted() async {
    await setOnboardingStep(4); // completed onboarding
  }

  // ============================
  // Final step: mark profile completed
  // ============================

  Future<void> markProfileCompleted() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _client.from("profiles").update({
      "is_profile_completed": true,
      "onboarding_step": 4,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq("id", user.id);
  }
}
