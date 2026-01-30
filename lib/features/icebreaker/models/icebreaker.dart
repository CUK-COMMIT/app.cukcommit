class Icebreaker {
  final String id;
  final String question;
  final String category;
  final int difficulty;
  final bool isPersonal;
  final List<String> tags;

  Icebreaker({
    required this.id,
    required this.question,
    required this.category,
    this.difficulty = 1,
    this.isPersonal = false,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'difficulty': difficulty,
      'isPersonal': isPersonal,
      'tags': tags,
    };
  }

  factory Icebreaker.fromMap(Map<String, dynamic> map) {
    return Icebreaker(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      category: map['category'] ?? 'General',
      difficulty: map['difficulty'] ?? 1,
      isPersonal: map['isPersonal'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}

class IcebreakerAnswer {
  final String id;
  final String icebreakerId;
  final String userId;
  final String answer;
  final DateTime createdAt;
  final bool isPublic;

  IcebreakerAnswer({
    required this.id,
    required this.icebreakerId,
    required this.userId,
    required this.answer,
    required this.createdAt,
    this.isPublic = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icebreakerId': icebreakerId,
      'userId': userId,
      'answer': answer,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isPublic': isPublic,
    };
  }

  factory IcebreakerAnswer.fromMap(Map<String, dynamic> map) {
    return IcebreakerAnswer(
      id: map['id'] ?? '',
      icebreakerId: map['icebreakerId'] ?? '',
      userId: map['userId'] ?? '',
      answer: map['answer'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? ''),
      isPublic: map['isPublic'] ?? true,
    );
  }
}
