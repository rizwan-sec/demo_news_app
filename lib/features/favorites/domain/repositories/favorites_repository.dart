import '../../../news/domain/entities/article.dart';

abstract class FavoritesRepository {
  List<Article> getAll();
  Future<void> add(Article article);
  Future<void> remove(String url);
}