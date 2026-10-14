import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/search_sort.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';
import '../models/article_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl(this._remote);

  final NewsRemoteDataSource _remote;

  @override
  Future<List<Article>> getTopHeadlines({
    required String category,
    required int page,
    required int pageSize,
  }) {
    return _guard(
          () => _remote.getTopHeadlines(
        category: category,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  @override
  Future<List<Article>> searchArticles({
    required String query,
    required SearchSort sort,
    required int page,
    required int pageSize,
  }) {
    return _guard(
          () => _remote.searchArticles(
        query: query,
        sortBy: sort.apiValue,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  /// Runs a request, maps the response to entities and converts every
  /// failure into a [Failure] with a user-friendly message.
  Future<List<Article>> _guard(
      Future<NewsResponseModel> Function() request,
      ) async {
    try {
      final response = await request();
      return (response.articles ?? const [])
          .where((a) =>
      a.url != null && a.title != null && a.title != '[Removed]')
          .map((a) => a.toEntity())
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (_) {
      throw const Failure('Unexpected data received from the server.');
    }
  }
}