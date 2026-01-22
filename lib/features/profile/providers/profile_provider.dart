import 'package:flutter/material.dart';
import '../models/pofile_details.dart';
import '../models/profile_photo.dart';
import '../repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;
  
  ProfileDetails? _profile;
  List<ProfilePhoto>? _photos = [];
  bool _isLoading = false;
  String? _error;

  ProfileProvider({required ProfileRepository repository})
    : _repository = repository{
      _loadUserProfile();
    }

  ProfileDetails? get profileDetails => _profile;
  List<ProfilePhoto>? get userPhotos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPremium => _profile?.isPremium ?? false;

  //load user profile
  Future<void> _loadUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try{
      _profile = await _repository.getProfileDetails("current_user");
      _photos = await _repository.getUserPhotos("current_user");
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileDetails(ProfileDetails details) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateProfile(details);
      _profile = details;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }  
  }

  Future<void> updateProfilePhoto(List<ProfilePhoto> updatedPhotos) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updatePhotos(updatedPhotos);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //update preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updatePreferences(preferences);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // upgrade to premium
  Future<void> upgradeToPremium() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.upgardeToPremium();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> getProfileDetails(String userId) async {
    _profile = await _repository.getProfileDetails(userId);
    notifyListeners();
  }

  Future<void> getUserPhotos(String userId) async {
    _photos = await _repository.getUserPhotos(userId);
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    await _loadUserProfile();
    // notifyListeners();
  }
}
