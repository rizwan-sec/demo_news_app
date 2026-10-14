import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/dio_client.dart';
import '../data/datasources/news_remote_data_source.dart';
import '../data/repositories/news_repository_impl.dart';
import '../domain/entities/article.dart';
import '../domain/repositories/news_repository.dart';

final newsRepositoryProvider = Provider<NewsRepository>(
      (ref) => NewsRepositoryImpl(NewsRemoteDataSource(ref.watch(dioProvider))),
);

class NewsFeedState {
  const NewsFeedState({
    this.category = 'general',
    this.articles = const [],
    this.page = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final String category;
  final List<Article> articles;
  final int page;
  final bool isLoading; // first load of a category
  final bool isLoadingMore; // next page
  final bool hasMore;
  final String? error;

  NewsFeedState copyWith({
    String? category,
    List<Article>? articles,
    int? page,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return NewsFeedState(
      category: category ?? this.category,
      articles: articles ?? this.articles,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NewsFeedNotifier extends Notifier<NewsFeedState> {
  static const _pageSize = 20;


  static const _maxPages = 5;

  @override
  NewsFeedState build() {
    Future.microtask(loadInitial);
    return const NewsFeedState(isLoading: true);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      articles: [],
      page: 1,
      hasMore: true,
      clearError: true,
    );
    await _fetch(page: 1, replace: true);
  }

  Future<void> refresh() => _fetch(page: 1, replace: true);

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    await _fetch(page: state.page + 1, replace: false);
  }

  Future<void> selectCategory(String category) async {
    if (category == state.category) return;
    state = NewsFeedState(category: category, isLoading: true);
    await _fetch(page: 1, replace: true);
  }

  Future<void> _fetch({required int page, required bool replace}) async {
    final category = state.category;
    try {
      final fetched = await ref.read(newsRepositoryProvider).getTopHeadlines(
        category: category,
        page: page,
        pageSize: _pageSize,
      );
      if (category != state.category) return;

      state = state.copyWith(
        articles: replace ? fetched : [...state.articles, ...fetched],
        page: page,
        isLoading: false,
        isLoadingMore: false,
        hasMore: fetched.isNotEmpty && page < _maxPages,
        clearError: true,
      );
    } on Failure catch (e) {
      if (category != state.category) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.message,
      );
    }
  }
}

final newsFeedProvider =
NotifierProvider<NewsFeedNotifier, NewsFeedState>(NewsFeedNotifier.new);