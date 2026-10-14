import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/article.dart';

part 'article_model.g.dart';

@JsonSerializable()
class SourceModel {
  const SourceModel({this.id, this.name});

  final String? id;
  final String? name;

  factory SourceModel.fromJson(Map<String, dynamic> json) =>
      _$SourceModelFromJson(json);
  Map<String, dynamic> toJson() => _$SourceModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ArticleModel {
  const ArticleModel({
    this.source,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  final SourceModel? source;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleModelToJson(this);

  Article toEntity() => Article(
    url: url ?? '',
    title: title ?? 'Untitled',
    description: description,
    content: content,
    imageUrl: urlToImage,
    sourceName: source?.name,
    author: author,
    publishedAt:
    publishedAt == null ? null : DateTime.tryParse(publishedAt!),
  );
}

@JsonSerializable(explicitToJson: true)
class NewsResponseModel {
  const NewsResponseModel({this.totalResults, this.articles});

  final int? totalResults;
  final List<ArticleModel>? articles;

  factory NewsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NewsResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$NewsResponseModelToJson(this);
}