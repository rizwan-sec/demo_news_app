import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl(this._remote);

  final NewsRemoteDataSource _remote;

  @override
  Future<List<Article>> getTopHeadlines({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _remote.getTopHeadlines(
        category: category,
        page: page,
        pageSize: pageSize,
      );
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