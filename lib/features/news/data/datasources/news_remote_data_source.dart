import 'package:dio/dio.dart';
import '../models/article_model.dart';

class NewsRemoteDataSource {
  NewsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<NewsResponseModel> getTopHeadlines({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    final res = await _dio.get(
      '/top-headlines',
      queryParameters: {
        'country': 'us', // other countries return very few results on free plan
        'category': category,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return NewsResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<NewsResponseModel> searchArticles({
    required String query,
    required String sortBy,
    required int page,
    required int pageSize,
  }) async {
    final res = await _dio.get(
      '/everything',
      queryParameters: {
        'q': query,
        'sortBy': sortBy,
        'language': 'en',
        'page': page,
        'pageSize': pageSize,
      },
    );
    return NewsResponseModel.fromJson(res.data as Map<String, dynamic>);
  }
}