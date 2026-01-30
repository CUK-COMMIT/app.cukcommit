import '../repositories/icebreaker_repository.dart';
import 'package:flutter/material.dart';
import '../models/icebreaker.dart';

class IcebreakerProvider with ChangeNotifier {
  final IcebreakerRepository _repository;

  List<Icebreaker> _icebreakers = [];
  Map<String, List<IcebreakerAnswer>> _userAnswers = {};
  Map<String, List<IcebreakerAnswer>> _matchAnswers = {};
  bool _isLoading = false;
  String? _error;

  IcebreakerProvider({required IcebreakerRepository repository})
    : _repository = repository {
    _loadIcebreakers();
  }

  // Getters
  List<Icebreaker> get icebreakers => _icebreakers;
  Map<String, List<IcebreakerAnswer>> get userAnswers => _userAnswers;
  // Map<String, List<IcebreakerAnswer>> get matchAnswers => _matchAnswers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadIcebreakers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _icebreakers = await _repository.getIcebreakers();
      _userAnswers = await _repository.getUserAnswers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAnswer(
    String icebreakerId,
    String answer, {
    bool isPublic = true,
  }) async {
    try {
      await _repository.saveAnswers(icebreakerId, answer, isPublic: isPublic);

      // update local state
      if (_userAnswers.containsKey(icebreakerId)) {
        _userAnswers[icebreakerId]!.add(
          IcebreakerAnswer(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            icebreakerId: icebreakerId,
            answer: answer,
            userId: "current_user",
            isPublic: isPublic,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        _userAnswers[icebreakerId] = [
          IcebreakerAnswer(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            icebreakerId: icebreakerId,
            answer: answer,
            userId: "current_user",
            isPublic: isPublic,
            createdAt: DateTime.now(),
          ),
        ];
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Icebreaker> getUnansweredIcebreaker() {
    return _icebreakers.where((icebreaker) => 
    !_userAnswers.containsKey(icebreaker.id) ||
    _userAnswers[icebreaker.id]!.isEmpty
    ).toList();
  } 

  List<Icebreaker> getAnsweredIcebreaker() {
    return _icebreakers.where((icebreaker) => 
    _userAnswers.containsKey(icebreaker.id) &&
    _userAnswers[icebreaker.id]!.isNotEmpty
    ).toList();
  }

  Future<void> loadMatchAnswers(String matchId) async {
    try{
      final answers = await _repository.getMatchAnswers(matchId);

      // group answers by icebreaker id
      final groupedAnswers = <String, List<IcebreakerAnswer>>{};
      for (var answer in answers) {
        if (!groupedAnswers.containsKey(answer.icebreakerId)) {
          groupedAnswers[answer.icebreakerId] = [answer];
        }
        groupedAnswers[answer.icebreakerId]!.add(answer);
      }
      _matchAnswers = groupedAnswers;
      notifyListeners();
    }catch(e){
      _error = e.toString();
      notifyListeners();
    }

  }

  List<IcebreakerAnswer> getMatchAnswersForIcebreaker(String icebreakerId) {
    return _matchAnswers[icebreakerId] ?? [];
  }


  Future<Icebreaker?> getSuggestedIcebreaker(String matchId) async {
    try{
      final icebreaker = await _repository.getSuggestedIcebreaker(matchId);
      return icebreaker;
    }catch(e){
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError(){
    _error = null;
    notifyListeners();
  }
}
