class Article {
  const Article({
    required this.url,
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.sourceName,
    this.author,
    this.publishedAt,
  });

  final String url; // unique id for favorites later
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final String? sourceName;
  final String? author;
  final DateTime? publishedAt;
}