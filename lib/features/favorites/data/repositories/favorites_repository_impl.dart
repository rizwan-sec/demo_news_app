import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../news/data/models/article_model.dart';
import '../../../news/domain/entities/article.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._box);

  final Box _box;

  @override
  List<Article> getAll() {
    final articles = <Article>[];
    for (final raw in _box.values) {
      try {
        final json = jsonDecode(raw as String) as Map<String, dynamic>;
        articles.add(ArticleModel.fromJson(json).toEntity());
      } catch (_) {
      }
    }
    return articles.reversed.toList(); // most recently saved first
  }

  @override
  Future<void> add(Article article) => _box.put(
    article.url,
    jsonEncode(ArticleModel.fromEntity(article).toJson()),
  );

  @override
  Future<void> remove(String url) => _box.delete(url);
}