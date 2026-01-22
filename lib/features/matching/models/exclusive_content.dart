class ExclusiveContent {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String content;
  final DateTime publishDate;
  final List<String> tags;
  final int requiredMonths;

  const ExclusiveContent({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.content,
    required this.publishDate,
    required this.tags,
    required this.requiredMonths,
  });

  //convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'content': content,
      'publish_date': publishDate.toIso8601String(),
      'tags': tags,
      'required_months': requiredMonths,
    };
  }

  //create from map
  factory ExclusiveContent.fromMap(Map<String, dynamic> map) {
    return ExclusiveContent(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      imageUrl: (map['image_url'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      publishDate: DateTime.tryParse((map['publish_date'] ?? '').toIso8601String()) ??
          DateTime.now(),
      tags: List<String>.from(map['tags'] ?? const []),
      requiredMonths: (map['required_months'] ?? 0) as int,
    );
  }

  factory ExclusiveContent.fromSupabase(Map<String, dynamic> map) {
    return ExclusiveContent(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      imageUrl: (map['image_url'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      publishDate: DateTime.tryParse((map['publish_date'] ?? '').toString()) ??
          DateTime.now(),
      tags: List<String>.from(map['tags'] ?? const []),
      requiredMonths: (map['required_months'] ?? 0) as int,
    );
  }
}
