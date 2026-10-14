import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../news/domain/entities/article.dart';
import '../data/repositories/favorites_repository_impl.dart';
import '../domain/repositories/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
      (ref) => FavoritesRepositoryImpl(Hive.box('favorites')),
);

class FavoritesNotifier extends Notifier<List<Article>> {
  @override
  List<Article> build() => ref.read(favoritesRepositoryProvider).getAll();

  Future<void> toggle(Article article) async {
    final repo = ref.read(favoritesRepositoryProvider);
    final isSaved = state.any((a) => a.url == article.url);
    if (isSaved) {
      await repo.remove(article.url);
    } else {
      await repo.add(article);
    }
    state = repo.getAll();
  }
}

final favoritesProvider =
NotifierProvider<FavoritesNotifier, List<Article>>(FavoritesNotifier.new);

/// Per-article flag, so a screen rebuilds only when *its* article changes.
final isFavoriteProvider = Provider.family<bool, String>((ref, url) {
  return ref.watch(favoritesProvider).any((a) => a.url == url);
});