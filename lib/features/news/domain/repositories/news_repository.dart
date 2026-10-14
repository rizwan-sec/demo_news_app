import '../entities/article.dart';
import '../entities/search_sort.dart';

abstract class NewsRepository {
  Future<List<Article>> getTopHeadlines({
    required String category,
    required int page,
    required int pageSize,
  });

  Future<List<Article>> searchArticles({
    required String query,
    required SearchSort sort,
    required int page,
    required int pageSize,
  });
}