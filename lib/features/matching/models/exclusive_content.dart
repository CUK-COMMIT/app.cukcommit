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
