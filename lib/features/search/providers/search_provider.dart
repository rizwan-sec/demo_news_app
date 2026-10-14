import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failure.dart';
import '../../news/domain/entities/article.dart';
import '../../news/domain/entities/search_sort.dart';
import '../../news/providers/news_provider.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.sort = SearchSort.relevancy,
    this.articles = const [],
    this.page = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  final String query;
  final SearchSort sort;
  final List<Article> articles;
  final int page;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  bool get hasQuery => query.length >= SearchNotifier.minChars;

  SearchState copyWith({
    List<Article>? articles,
    SearchSort? sort,
    int? page,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      query: query,
      sort: sort ?? this.sort,
      articles: articles ?? this.articles,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  static const minChars = 2;
  static const _debounceDuration = Duration(milliseconds: 500);
  static const _pageSize = 20;

  static const _maxPages = 5;

  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  void onQueryChanged(String input) {
    final query = input.trim();
    if (query == state.query) return;

    _debounce?.cancel();

    if (query.length < minChars) {
      state = SearchState(query: query, sort: state.sort);
      return;
    }

    // Show the loader right away, but hit the API only after the user pauses.
    state = SearchState(query: query, sort: state.sort, isLoading: true);
    _debounce = Timer(_debounceDuration, () => _fetch(page: 1, replace: true));
  }

  void setSort(SearchSort sort) {
    if (sort == state.sort) return;
    _debounce?.cancel();

    if (!state.hasQuery) {
      state = state.copyWith(sort: sort);
      return;
    }
    state = SearchState(query: state.query, sort: sort, isLoading: true);
    _fetch(page: 1, replace: true);
  }

  Future<void> retry() {
    state = state.copyWith(isLoading: true, clearError: true);
    return _fetch(page: 1, replace: true);
  }

  Future<void> loadMore() async {
    if (!state.hasQuery ||
        state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, clearError: true);
    await _fetch(page: state.page + 1, replace: false);
  }

  Future<void> _fetch({required int page, required bool replace}) async {
    final query = state.query;
    final sort = state.sort;
    bool isStale() => query != state.query || sort != state.sort;

    try {
      final fetched = await ref.read(newsRepositoryProvider).searchArticles(
        query: query,
        sort: sort,
        page: page,
        pageSize: _pageSize,
      );
      if (isStale()) return; // user typed something else meanwhile

      state = state.copyWith(
        articles: replace ? fetched : [...state.articles, ...fetched],
        page: page,
        isLoading: false,
        isLoadingMore: false,
        hasMore: fetched.isNotEmpty && page < _maxPages,
        clearError: true,
      );
    } on Failure catch (e) {
      if (isStale()) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.message,
      );
    }
  }
}

final searchProvider =
NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);