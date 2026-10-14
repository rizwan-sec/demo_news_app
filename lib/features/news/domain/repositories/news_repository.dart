import '../entities/article.dart';

abstract class NewsRepository {
  Future<List<Article>> getTopHeadlines({
    required String category,
    required int page,
    required int pageSize,
  });
}