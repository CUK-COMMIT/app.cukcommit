import 'package:flutter/widgets.dart';

import '../models/icebreaker.dart';

class IcebreakerRepository {
  // This will be replaced with supabase later
  Future<List<Icebreaker>> getIcebreakers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    //mock data -- will be relaced with supabase later
    return [
      Icebreaker(
        id: "1",
        question: "What is your favorite food?",
        tags: ["food", "favorite"],
        category: "Personal",
        isPersonal: true,
        difficulty: 2,
      ),
      Icebreaker(
        id: "2",
        question: "What is your favorite movie?",
        tags: ["movie", "favorite"],
        category: "Entertainment",
        isPersonal: true,
        difficulty: 2,
      ),
      Icebreaker(
        id: "3",
        question: "What is your favorite color?",
        tags: ["color", "favorite"],
        category: "Personal",
        isPersonal: true,
        difficulty: 2,
      ),
    ];
  }

  // This will be replaced with supabase later
  Future<Map<String, List<IcebreakerAnswer>>> getUserAnswers(
    {String? userId}
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    //mock data -- will be relaced with supabase later
    final currentUserId = userId ?? "current_user";

    return {
      '1': [
        IcebreakerAnswer(
          id: "1",
          icebreakerId: "1",
          userId: currentUserId,
          answer: "I like pizza",
          createdAt: DateTime(2025, 9, 19),
        ),
      ],
      '2': [
        IcebreakerAnswer(
          id: "2",
          icebreakerId: "2",
          userId: currentUserId,
          answer: "I like Godfather",
          createdAt: DateTime(2025, 9, 19),
        ),
      ],
      '3': [
        IcebreakerAnswer(
          id: "3",
          icebreakerId: "3",
          userId: currentUserId,
          answer: "I like pink",
          createdAt: DateTime(2025, 9, 19),
        ),
      ],
    };
  }

  Future<void> saveAnswers(
    String icebreakerId,
    String answer, {
    String? userId,
    bool isPublic = true,
  }) async {
    //Simulate network delay
    Future.delayed(const Duration(milliseconds: 300));

    //save data to supabase
    final currentUserId = userId ?? 'current_user';

    final newAnswer = IcebreakerAnswer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      icebreakerId: icebreakerId,
      userId: currentUserId,
      answer: answer,
      createdAt: DateTime.now(),
      isPublic: isPublic,
    );

    //save to supabase
    debugPrint('Saved Answers: ${newAnswer.toMap()}');
  }

  Future<List<IcebreakerAnswer>> getMatchAnswers(String matchId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    //mock data -- will be relaced with supabase later
    return [
      IcebreakerAnswer(
        id: "1",
        icebreakerId: "1",
        userId: matchId,
        answer: "I like pizza",
        createdAt: DateTime(2025, 9, 19),
      ),
      IcebreakerAnswer(
        id: "2",
        icebreakerId: "2",
        userId: matchId,
        answer: "I like Godfather",
        createdAt: DateTime(2025, 9, 19),
      ),
      IcebreakerAnswer(
        id: "3",
        icebreakerId: "3",
        userId: matchId,
        answer: "I like pink",
        createdAt: DateTime(2025, 9, 19),
      ),
    ];
  }

  Future<Icebreaker?> getSuggestedIcebreaker(String matchId) async {
    //This would use an algorithm to suggest an icebreaker based on;
    // 1. Questions the match has already answered
    // 2. Questions the user hasn't asked yet
    // 3. Common interests
    await Future.delayed(const Duration(milliseconds: 300));

    // for now, just return a random icebreaker
    final icebreakers = await getIcebreakers();
    icebreakers.shuffle();
    return icebreakers.isNotEmpty ? icebreakers.first : null;
  }
}
