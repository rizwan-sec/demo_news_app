import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../errors/failure.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'X-Api-Key': ApiConstants.apiKey},
    ),
  );
});

Failure mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const Failure('Request timed out. Please try again.');
    case DioExceptionType.connectionError:
      return const Failure('No internet connection.');
    default:
      final data = e.response?.data;
      final msg = data is Map ? data['message'] as String? : null;
      return Failure(msg ?? 'Something went wrong. Please try again.');
  }
}