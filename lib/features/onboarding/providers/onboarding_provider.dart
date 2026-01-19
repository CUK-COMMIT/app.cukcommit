import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cuk_commit/core/services/supabase_storage_service.dart';
import 'package:cuk_commit/features/onboarding/repositories/onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingProvider extends ChangeNotifier {
  final OnboardingRepository _repository;

  OnboardingProvider({
    required OnboardingRepository repository,
  }) : _repository = repository;

  static const int maxPhotos = 6;

  // ============================
  // User data
  // ============================
  String _name = '';
  DateTime? _birthDate;

  String _gender = '';
  String _relationshipGoal = '';
  String _matchPreference = '';

  final List<String> _interests = [];

  // ============================
  // Student Verification
  // ============================
  String _rollNo = ''; // auto-filled by barcode scan
  String _department = '';
  String _year = '';
  String _program = ''; // UG / PG / PhD

  String? _studentIdPhotoUrl;

  // slot based photos
  final List<String?> _photoSlots = List<String?>.filled(maxPhotos, null);

  // ============================
  // Upload state
  // ============================
  bool _isUploading = false;
  int _uploadingIndex = -1;

  bool get isUploading => _isUploading;
  int get uploadingIndex => _uploadingIndex;

  void _setUploading(bool value, {int index = -1}) {
    _isUploading = value;
    _uploadingIndex = value ? index : -1;
    notifyListeners();
  }

  // ============================
  // Getters
  // ============================
  String get name => _name;
  DateTime? get birthDate => _birthDate;

  String get gender => _gender;
  String get relationshipGoal => _relationshipGoal;
  String get matchPreference => _matchPreference;

  List<String> get interests => List.unmodifiable(_interests);

  List<String?> get photoSlots => List.unmodifiable(_photoSlots);

  /// only uploaded photo urls
  List<String> get photos => _photoSlots.whereType<String>().toList();

  int get uploadedCount => photos.length;
  bool get hasMinPhotos => uploadedCount >= 2;

  // student verification getters
  String get rollNo => _rollNo;
  String get department => _department;
  String get year => _year;
  String get program => _program;
  String? get studentIdPhotoUrl => _studentIdPhotoUrl;

  bool get isProfileFormValid =>
      _gender.trim().isNotEmpty &&
      _relationshipGoal.trim().isNotEmpty &&
      _matchPreference.trim().isNotEmpty;

  bool get isInterestsValid => _interests.isNotEmpty;

  bool get isStudentVerificationValid =>
      _rollNo.trim().isNotEmpty &&
      _department.trim().isNotEmpty &&
      _year.trim().isNotEmpty &&
      _program.trim().isNotEmpty &&
      (_studentIdPhotoUrl ?? '').trim().isNotEmpty;

  // ============================
  // Setters
  // ============================
  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateBirthDate(DateTime? value) {
    _birthDate = value;
    notifyListeners();
  }

  void updateGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void updateRelationshipGoal(String value) {
    _relationshipGoal = value;
    notifyListeners();
  }

  void updateMatchPreference(String value) {
    _matchPreference = value;
    notifyListeners();
  }

  void toggleInterest(String interest) {
    if (_interests.contains(interest)) {
      _interests.remove(interest);
    } else {
      _interests.add(interest);
    }
    notifyListeners();
  }

  // Student verification setters
  void setRollNo(String value) {
    _rollNo = value.trim();
    notifyListeners();
  }

  void updateDepartment(String value) {
    _department = value;
    notifyListeners();
  }

  void updateYear(String value) {
    _year = value;
    notifyListeners();
  }

  void updateProgram(String value) {
    _program = value;
    notifyListeners();
  }

  // ============================
  // Slot Helpers
  // ============================
  bool _isValidSlot(int i) => i >= 0 && i < maxPhotos;

  void setPhotoSlot(int slotIndex, String? url) {
    if (!_isValidSlot(slotIndex)) return;
    _photoSlots[slotIndex] = url;
    notifyListeners();
  }

  // ============================
  // Load existing onboarding data
  // ============================

  /// Call this when onboarding screens open (or after login)
  /// Loads photo slots from DB (NOT storage listing)
  Future<void> loadMyPhotosFromDb() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final rows = await _repository.getMyPhotos();

    // clear first
    for (int i = 0; i < _photoSlots.length; i++) {
      _photoSlots[i] = null;
    }

    for (final row in rows) {
      final slotIndex = row["slot_index"] as int;
      final url = row["url"] as String;
      if (_isValidSlot(slotIndex)) {
        _photoSlots[slotIndex] = url;
      }
    }

    notifyListeners();
  }

  // ============================
  // Photos Upload (Slot-based)
  // ============================

  /// Uploads to storage + saves to profile_photos (DB)
  Future<String> uploadPhotoToSupabase({
    required File file,
    required int slotIndex,
  }) async {
    if (!_isValidSlot(slotIndex)) {
      throw Exception("Invalid photo slot index: $slotIndex");
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in (Supabase session missing)");
    }

    _setUploading(true, index: slotIndex);

    try {
      final signedUrl = await SupabaseStorageService.uploadUserPhotoSigned(
        file: file,
        uid: user.id,
        slotIndex: slotIndex,
      );

      await _repository.upsertPhotoSlot(
        slotIndex: slotIndex,
        url: signedUrl,
        isPrimary: slotIndex == 0,
      );

      _photoSlots[slotIndex] = signedUrl;
      notifyListeners();

      return signedUrl;
    } finally {
      _setUploading(false);
    }
  }

  /// Remove photo from DB + storage
  Future<void> removePhotoAt(int slotIndex) async {
    if (!_isValidSlot(slotIndex)) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final url = _photoSlots[slotIndex];
    if (url == null) return;

    _photoSlots[slotIndex] = null;
    notifyListeners();

    try {
      await _repository.deletePhotoSlot(slotIndex: slotIndex);

      await SupabaseStorageService.deleteUserPhotoBySlot(
        uid: user.id,
        slotIndex: slotIndex,
      );
    } catch (e) {
      debugPrint("Remove photo failed: $e");
    }
  }

  // ============================
  // Student ID Photo Upload
  // ============================

  /// Upload ID photo into storage and store URL locally
  /// NOTE: you can later move it into repository if you want.
  Future<String> uploadStudentIdPhoto({
    required File file,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in (Supabase session missing)");
    }

    _setUploading(true, index: 999);

    try {
      final signedUrl = await SupabaseStorageService.uploadStudentIdSigned(
        file: file,
        uid: user.id,
      );

      _studentIdPhotoUrl = signedUrl;
      notifyListeners();

      return signedUrl;
    } finally {
      _setUploading(false);
    }
  }


  // ============================
  // Step 0 -> 1 : Save profile setup
  // ============================
  Future<void> saveProfileSetupStep() async {
    if (!isProfileFormValid) {
      throw Exception("Profile form incomplete");
    }

    await _repository.saveUserProfileData(
      name: _name.trim(),
      gender: _gender.trim(),
      relationshipGoal: _relationshipGoal.trim(),
      matchPreference: _matchPreference.trim(),
    );
  }

  // ============================
  // Step 1 -> 2 : Complete photo step
  // ============================
  Future<void> completePhotoStep() async {
    if (!hasMinPhotos) {
      throw Exception("Upload at least 2 photos");
    }
    await _repository.completePhotoStep();
  }

  // ============================
  // Step 2 -> 3 : Interests step complete
  // ============================
  Future<void> completeInterestsStep() async {
    if (_interests.isEmpty) {
      throw Exception("Select at least 1 interest");
    }

    await _repository.saveInterests(_interests);

    // Step 3 = Student Verification
    await _repository.markInterestsCompleted();
  }

  // ============================
  // Step 3 -> 4 : Student verification submit
  // ============================
  Future<void> submitStudentVerification() async {
    if (!isStudentVerificationValid) {
      throw Exception("Student verification incomplete");
    }

    await _repository.saveStudentVerification(
      rollNo: _rollNo,
      department: _department,
      year: _year,
      program: _program,
      idPhotoUrl: _studentIdPhotoUrl!,
    );

    // move step to 4
    await _repository.markStudentVerificationSubmitted();

    // finally mark complete
    await _repository.markProfileCompleted();
  }

  // ============================
  // Reset
  // ============================
  void reset() {
    _name = '';
    _birthDate = null;
    _gender = '';
    _relationshipGoal = '';
    _matchPreference = '';
    _interests.clear();

    _rollNo = '';
    _department = '';
    _year = '';
    _program = '';
    _studentIdPhotoUrl = null;

    for (int i = 0; i < _photoSlots.length; i++) {
      _photoSlots[i] = null;
    }

    _isUploading = false;
    _uploadingIndex = -1;

    notifyListeners();
  }
}
