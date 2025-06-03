class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'].toString(), // Supabase ID can be int or uuid
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
    );
  }
}