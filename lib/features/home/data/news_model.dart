// features/home/data/news_model.dart

class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String? imageUrl; // ¡Ahora es nullable!

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl, // Ya no es 'required'
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'].toString(), // O puedes usar json['id'] as String si es UUID
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?, // Castea a String? para manejar nulos
    );
  }
}